
const { Router } = require('express');
const connection = require('../database/db');

// Postres
exports.save_postres = (req, res) => {
    const NOMBRE = req.body.NOMBRE;
    const PRECIO = req.body.PRECIO;
    const DESCRIPCION = req.body.DESCRIPCION;

    const FOTO = req.file ? req.file.filename : null; 

    console.log(NOMBRE, PRECIO, DESCRIPCION, FOTO);

    connection.query(
        'INSERT INTO POSTRES (NOMBRE, PRECIO, FOTO, DESCRIPCION, ESTADO) VALUES (?, ?, ?, ?, ?)',
        [NOMBRE, PRECIO, FOTO, DESCRIPCION, 1], 
        (error, results) => {
            if (error) {
                console.error(error);
                return res.status(500).send('Error en la base de datos');
            }
            req.session.message = 'Agregado con Éxito';
            res.redirect('/postres');
        }
    );
};

exports.update_postres = (req, res) => {
    const IDPOSTRES = req.body.IDPOSTRES;
    const NOMBRE = req.body.NOMBRE;
    const PRECIO = req.body.PRECIO;
    const DESCRIPCION = req.body.DESCRIPCION;

    // Si se ha subido un archivo nuevo, lo usamos; de lo contrario, mantenemos la imagen existente
    const FOTO = req.file ? req.file.filename : req.body.existingFoto;

    connection.query(
        'UPDATE POSTRES SET NOMBRE = ?, PRECIO = ?, FOTO = ?, DESCRIPCION = ? WHERE IDPOSTRES = ?',
        [NOMBRE, PRECIO, FOTO, DESCRIPCION, IDPOSTRES],
        (error, results) => {
            if (error) {
                console.error(error);
            }
            req.session.message = 'Actualizado con Éxito';
            res.redirect('/postres');
        }
    );
};

