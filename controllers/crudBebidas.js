
const { Router } = require('express');
const connection = require('../database/db');

// Bebidas
exports.save_bebidas = (req, res) => {
    const NOMBRE = req.body.NOMBRE;
    const PRECIO = req.body.PRECIO;
    const DESCRIPCION = req.body.DESCRIPCION;
    const IDCATEGORIA = req.body.IDCATEGORIA;

    const FOTO = req.file ? req.file.filename : null; 

    console.log(NOMBRE, PRECIO, DESCRIPCION, IDCATEGORIA, FOTO);

    connection.query(
        'INSERT INTO BEBIDAS (NOMBRE, PRECIO, FOTO, DESCRIPCION, IDCATEGORIA, ESTADO) VALUES (?, ?, ?, ?, ?, ?)',
        [NOMBRE, PRECIO, FOTO, DESCRIPCION, IDCATEGORIA, 1], 
        (error, results) => {
            if (error) {
                console.error(error);
                return res.status(500).send('Error en la base de datos');
            }
            req.session.message = 'Agregado con Éxito';
            res.redirect('/bebidas');
        }
    );
};


exports.update_bebidas = (req, res) => {
    const IDBEBIDAS = req.body.IDBEBIDAS;
    const IDCATEGORIA = req.body.IDCATEGORIA;
    const NOMBRE = req.body.NOMBRE;
    const PRECIO = req.body.PRECIO;
    const DESCRIPCION = req.body.DESCRIPCION;

    // Si se ha subido un archivo nuevo, lo usamos; de lo contrario, mantenemos la imagen existente
    const FOTO = req.file ? req.file.filename : req.body.existingFoto;

    connection.query(
        'UPDATE BEBIDAS SET NOMBRE = ?, PRECIO = ?, FOTO = ?, DESCRIPCION = ?, IDCATEGORIA = ? WHERE IDBEBIDAS = ?',
        [NOMBRE, PRECIO, FOTO, DESCRIPCION, IDCATEGORIA, IDBEBIDAS],
        (error, results) => {
            if (error) {
                console.error(error);
            }
            req.session.message = 'Actualizado con Éxito';
            res.redirect('/bebidas');
        }
    );
};



