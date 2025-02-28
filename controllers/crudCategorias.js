
const { Router } = require('express');
const connection = require('../database/db');

// Usuarios
exports.save_categorias = (req, res) => {
    const NOMBRE = req.body.NOMBRE;

    console.log(NOMBRE);
    connection.query('INSERT INTO CATEGORIAS SET NOMBRE = ?, ESTADO = 1', [NOMBRE], (error, results) => {
        if (error) {
            console.log(error);
        } else {
            req.session.message = 'Agregado con Éxito';
            res.redirect('/categorias');
        }
    });
}


exports.update_categorias = (req, res) => {
    const IDCATEGORIA = req.body.IDCATEGORIA;
    const NOMBRE = req.body.NOMBRE;
    
    console.log(NOMBRE);
    connection.query('UPDATE CATEGORIAS SET NOMBRE = ? WHERE IDCATEGORIA = ?', [NOMBRE, IDCATEGORIA], (error, results) => {
        if (error) {
            console.log(error);
        } else {
            req.session.message = 'Actualizado con Éxito';
            res.redirect('/categorias');
        }
    });
}

