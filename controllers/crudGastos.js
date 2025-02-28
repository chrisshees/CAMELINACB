const { Router } = require('express');
const connection = require('../database/db');

exports.save_gastos = (req, res) => {
    const FECHA = req.body.FECHA;
    const MONTO = req.body.MONTO;
    const DESCRIPCION = req.body.DESCRIPCION;
    const REALIZADO_POR = req.body.REALIZADO_POR;
    const ACCION = req.query.accion;

    console.log(FECHA, MONTO, DESCRIPCION, REALIZADO_POR, ACCION);

    connection.query('INSERT INTO GASTOS (FECHA, MONTO, DESCRIPCION, ESTADO, REALIZADO_POR, ACCION) VALUES (?, ?, ?, ?, ?, ?)', [FECHA, MONTO, DESCRIPCION, 1, REALIZADO_POR, ACCION], (error, results) => {
        if (error) {
            console.log(error);
            req.session.message = 'Error al registrar el gasto';
            return res.redirect('/gastos');
        }

        if (ACCION === '1') {
            // Restar el monto del gasto de la caja
            connection.query('UPDATE CONTROLCAJA SET MONTOACTUAL = MONTOACTUAL - ?, TOTALCAJA = TOTALCAJA - ? WHERE FECHA = CURDATE()', [MONTO, MONTO], (error, results) => {
                if (error) {
                    console.log(error);
                    req.session.message = 'Error al actualizar el monto actual de la caja';
                    return res.redirect('/gastos');
                }

                req.session.message = 'Gasto registrado con éxito y monto actual de la caja actualizado';
                return res.redirect('/gastos');
            });
        } else {
            req.session.message = 'Gasto registrado con éxito';
            return res.redirect('/gastos');
        }
    });
};

exports.update_gastos = (req, res) => {
    const IDGASTOS = req.body.IDGASTOS;
    const MONTO = req.body.MONTO;
    const DESCRIPCION = req.body.DESCRIPCION;
    const REALIZADO_POR = req.body.REALIZADO_POR;

    console.log(IDGASTOS, MONTO, DESCRIPCION, REALIZADO_POR);

    // Obtener el monto anterior y la acción del gasto
    connection.query('SELECT MONTO, ACCION FROM GASTOS WHERE IDGASTOS = ?', [IDGASTOS], (error, results) => {
        if (error) {
            console.log(error);
            req.session.message = 'Error al obtener el monto anterior del gasto';
            return res.redirect('/gastos');
        }

        const montoAnterior = results[0].MONTO;
        const ACCION = results[0].ACCION;

        // Actualizar el gasto en la base de datos
        connection.query('UPDATE GASTOS SET MONTO = ?, DESCRIPCION = ?, REALIZADO_POR = ? WHERE IDGASTOS = ?', [MONTO, DESCRIPCION, REALIZADO_POR, IDGASTOS], (error, results) => {
            if (error) {
                console.log(error);
                req.session.message = 'Error al actualizar el gasto';
                return res.redirect('/gastos');
            }

            if (ACCION === 1) {
                // Calcular la diferencia entre el monto anterior y el nuevo monto
                const diferencia = MONTO - montoAnterior;

                // Actualizar el monto actual y el total de caja en la tabla CONTROLCAJA
                if (diferencia > 0) {
                    // Si la diferencia es positiva, restar la diferencia
                    connection.query('UPDATE CONTROLCAJA SET MONTOACTUAL = MONTOACTUAL - ?, TOTALCAJA = TOTALCAJA - ? WHERE FECHA = CURDATE()', [diferencia, diferencia], (error, results) => {
                        if (error) {
                            console.log(error);
                            req.session.message = 'Error al actualizar el monto actual de la caja';
                            return res.redirect('/gastos');
                        }

                        req.session.message = 'Gasto actualizado con éxito y monto actual de la caja actualizado';
                        return res.redirect('/gastos');
                    });
                } else {
                    // Si la diferencia es negativa, sumar la diferencia
                    connection.query('UPDATE CONTROLCAJA SET MONTOACTUAL = MONTOACTUAL + ?, TOTALCAJA = TOTALCAJA + ? WHERE FECHA = CURDATE()', [-diferencia, -diferencia], (error, results) => {
                        if (error) {
                            console.log(error);
                            req.session.message = 'Error al actualizar el monto actual de la caja';
                            return res.redirect('/gastos');
                        }

                        req.session.message = 'Gasto actualizado con éxito y monto actual de la caja actualizado';
                        return res.redirect('/gastos');
                    });
                }
            } else {
                req.session.message = 'Gasto actualizado con éxito';
                return res.redirect('/gastos');
            }
        });
    });
};


