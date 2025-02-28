const { Router } = require('express');
const connection = require('../database/db');

exports.verificarCaja = (req, res, next) => {
    const IDUSUARIO = req.session.userId;

    // Verificar si ya se ha abierto la caja hoy
    connection.query('SELECT * FROM CONTROLCAJA WHERE FECHA = CURDATE()', (error, results) => {
        if (error) {
            console.error('Error al verificar la caja:', error);
            req.session.message = 'Error al verificar la caja';
            return next(); // Continuar con la siguiente función de middleware
        }

        if (results.length > 0) {
            // La caja ya está abierta hoy
            req.session.cajaAbierta = true;
            req.session.cajaCerrada = results[0].ESTADO === 2; // Verificar si la caja está cerrada
            req.session.controlCaja = results[0]; // Guardar los datos de la caja en la sesión
        } else {
            // La caja no está abierta hoy
            req.session.cajaAbierta = false;
            req.session.cajaCerrada = false;
            req.session.controlCaja = null; // No hay datos de la caja
        }
        return next(); // Continuar con la siguiente función de middleware
    });
};

exports.abrirCaja = (req, res, next) => {
    const IDUSUARIO = req.session.userId;
    const INICIODIA = req.body.INICIODIA || 0; // Puedes ajustar esto según tus necesidades

    // Abrir la caja para hoy
    connection.query('INSERT INTO CONTROLCAJA (FECHA, INICIODIA, TOTALCAJA, MONTOACTUAL, IDUSUARIO, ESTADO) VALUES (CURDATE(), ?, ?, ?, ?, 1)', [INICIODIA, INICIODIA, INICIODIA, IDUSUARIO], (error, results) => {
        if (error) {
            console.error('Error al abrir la caja:', error);
            req.session.message = 'Error al abrir la caja';
            return res.redirect('/dashboard');
        }

        req.session.message = 'Caja abierta con éxito';
        return res.redirect('/dashboard');
    });
};

exports.cerrarCaja = (req, res, next) => {
    const IDCONTROLCAJA = req.body.IDCONTROLCAJA;

    // Obtener el TOTALCAJA para actualizar FINDIA
    connection.query('SELECT TOTALCAJA FROM controlcaja WHERE IDCONTROLCAJA = ?', [IDCONTROLCAJA], (error, results) => {
        if (error) {
            console.error('Error al obtener TOTALCAJA:', error);
            return res.status(500).send('Error en la base de datos');
        }

        const TOTALCAJA = results[0].TOTALCAJA;

        // Actualizar ESTADO a 2 y FINDIA con el valor de TOTALCAJA
        connection.query('UPDATE controlcaja SET ESTADO = 2, FINDIA = ? WHERE IDCONTROLCAJA = ?', [TOTALCAJA, IDCONTROLCAJA], (error, results) => {
            if (error) {
                console.error('Error al cerrar la caja:', error);
                return res.status(500).send('Error en la base de datos');
            }

            req.session.message = 'Caja cerrada con éxito';
            req.session.cajaAbierta = false; // Establecer cajaAbierta a false
            req.session.cajaCerrada = true; // Establecer cajaCerrada a true
            res.redirect('/dashboard'); // Redirigir a la página del dashboard o donde corresponda
        });
    });
};

exports.reabrirCaja = (req, res, next) => {
    const IDCONTROLCAJA = req.body.IDCONTROLCAJA;

    // Verificar si la fecha actual es la misma que la fecha de apertura de la caja
    connection.query('SELECT FECHA FROM CONTROLCAJA WHERE IDCONTROLCAJA = ?', [IDCONTROLCAJA], (error, results) => {
        if (error) {
            console.error('Error al verificar la fecha de la caja:', error);
            req.session.message = 'Error al verificar la fecha de la caja';
            return res.redirect('/dashboard');
        }

        const fechaCaja = new Date(results[0].FECHA);
        const fechaActual = new Date();

        if (fechaCaja.toDateString() === fechaActual.toDateString()) {
            // La fecha es la misma, reabrir la caja
            connection.query('UPDATE CONTROLCAJA SET ESTADO = 1, FINDIA = 0 WHERE IDCONTROLCAJA = ?', [IDCONTROLCAJA], (error, results) => {
                if (error) {
                    console.error('Error al reabrir la caja:', error);
                    req.session.message = 'Error al reabrir la caja';
                    return res.redirect('/dashboard');
                }

                req.session.message = 'Caja reabierta con éxito';
                req.session.cajaAbierta = true;
                req.session.cajaCerrada = false;
                return res.redirect('/dashboard');
            });
        } else {
            // La fecha es diferente, abrir una nueva caja
            const INICIODIA = 0; // Puedes ajustar esto según tus necesidades
            const IDUSUARIO = req.session.userId;

            connection.query('INSERT INTO CONTROLCAJA (FECHA, INICIODIA, TOTALCAJA, MONTOACTUAL, IDUSUARIO, ESTADO) VALUES (CURDATE(), ?, ?, ?, ?, 1)', [INICIODIA, INICIODIA, INICIODIA, IDUSUARIO], (error, results) => {
                if (error) {
                    console.error('Error al abrir una nueva caja:', error);
                    req.session.message = 'Error al abrir una nueva caja';
                    return res.redirect('/dashboard');
                }

                req.session.message = 'La fecha ha cambiado, se abrirá un nuevo registro de caja';
                req.session.cajaAbierta = true;
                req.session.cajaCerrada = false;
                return res.redirect('/dashboard');
            });
        }
    });
};

exports.save_notas = (req, res, next) => {

    const IDCONTROLCAJA = req.body.IDCONTROLCAJA;
    const NOTAS = req.body.NOTAS;

    connection.query('UPDATE CONTROLCAJA SET NOTAS = ? WHERE IDCONTROLCAJA = ?', [NOTAS, IDCONTROLCAJA], (error, results) => {
        if (error) {
            console.error('Error al guardar las notas:', error);
            return res.status(500).send('Error en la base de datos');
        }

        req.session.message = 'Notas guardadas con éxito';
        return res.redirect('/historialCaja');
    });
}