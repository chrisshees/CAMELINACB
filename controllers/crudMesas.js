
const { Router } = require('express');
const connection = require('../database/db');

//mesas
exports.save_mesas = (req, res) => {
    const NOMBRE = req.body.NOMBRE;
    const IDAREA = req.body.IDAREA;

    console.log(NOMBRE, IDAREA);

    connection.query(
        'SELECT * FROM MESAS WHERE NOMBRE = ? AND IDAREA = ? AND ESTADO = 1',
        [NOMBRE, IDAREA],
        (error, results) => {
            if (error) {
                console.log(error);
                res.status(500).send('Error en la consulta');
                return;
            }

            if (results.length > 0) {
                req.session.message = 'La mesa ya existe en esta área.';
                res.redirect('/mesas');
            } else {
                connection.query(
                    'INSERT INTO MESAS SET NOMBRE = ?, DISPONIBLE = 1, ESTADO = 1, IDAREA = ?',
                    [NOMBRE, IDAREA],
                    (insertError, insertResults) => {
                        if (insertError) {
                            console.log(insertError);
                            req.session.message = 'Error al agregar la mesa.';
                        } else {
                            req.session.message = 'Agregado con Éxito';
                        }
                        res.redirect('/mesas');
                    }
                );
            }
        }
    );
}

exports.update_mesas = (req, res) => {
    const IDMESA = req.body.IDMESA;
    const NOMBRE = req.body.NOMBRE;
    const IDAREA = req.body.IDAREA;

    connection.query(
        'UPDATE MESAS SET NOMBRE = ?, IDAREA = ? WHERE IDMESA = ?',
        [NOMBRE, IDAREA, IDMESA],
        (error, results) => {
            if (error) {
                console.log(error);
                req.session.message = 'Error al actualizar la mesa.';
            } else {
                req.session.message = 'Actualizado con Éxito';
            }
            res.redirect('/mesas');
        }
    );
}   
