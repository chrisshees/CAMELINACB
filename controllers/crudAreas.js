
const { Router } = require('express');
const connection = require('../database/db');

// Usuarios
exports.save_areas = (req, res) => {
    const NOMBRE_AREA = req.body.NOMBRE_AREA;

    console.log(NOMBRE_AREA);
    connection.query('INSERT INTO AREAS SET NOMBRE_AREA = ?, ESTADO = 1', [NOMBRE_AREA], (error, results) => {
        if (error) {
            console.log(error);
        } else {
            req.session.message = 'Agregado con Éxito';
            res.redirect('/areas');
        }
    });
}


exports.update_areas = (req, res) => {
    const IDAREA = req.body.IDAREA;
    const NOMBRE_AREA = req.body.NOMBRE_AREA;
    
    console.log(NOMBRE_AREA);
    connection.query('UPDATE AREAS SET NOMBRE_AREA = ? WHERE IDAREA = ?', [NOMBRE_AREA, IDAREA], (error, results) => {
        if (error) {
            console.log(error);
        } else {
            req.session.message = 'Actualizado con Éxito';
            res.redirect('/areas');
        }
    });
}

