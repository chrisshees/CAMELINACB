
const { Router } = require('express');
const connection = require('../database/db');

// Usuarios
exports.save_usuarios = (req, res) => {
    const NOMBREDEUSUARIO = req.body.NOMBREDEUSUARIO;
    const PASSWORD = req.body.PASSWORD;
    const TIPO = req.body.TIPO;
    const NOMBRE = req.body.NOMBRE;
    const APELLIDOPATERNO = req.body.APELLIDOPATERNO;
    const APELLIDOMATERNO = req.body.APELLIDOMATERNO;


    console.log(NOMBREDEUSUARIO, PASSWORD, TIPO, NOMBRE, APELLIDOPATERNO, APELLIDOMATERNO);

    // Verificar si el nombre de usuario ya existe
    connection.query('SELECT * FROM USUARIOS WHERE NOMBREDEUSUARIO = ? AND ESTADO = 1', [NOMBREDEUSUARIO], (error, results) => {
        if (error) {
            console.log(error);
        } else {
            if (results.length > 0) {
                // El nombre de usuario ya existe
                req.session.message = 'El nombre de usuario ya existe. Por favor, intenta con un nombre de usuario diferente.';
                res.redirect('/usuarios');

            } else {
                // El nombre de usuario no existe, proceder a insertar el nuevo usuario
                connection.query('INSERT INTO PERSONA SET NOMBRE = ?, APELLIDOPATERNO = ?, APELLIDOMATERNO = ?, ESTADO = 1', [NOMBRE, APELLIDOPATERNO, APELLIDOMATERNO], (error, results) => {
                    if (error) {
                        console.log(error);
                    } else {
                        const idPersona = results.insertId;
                        connection.query('INSERT INTO USUARIOS SET IDPERSONA = ?, NOMBREDEUSUARIO = ?, PASSWORD = ?, TIPO = ?, ESTADO = 1', [idPersona, NOMBREDEUSUARIO, PASSWORD, TIPO], (error, results) => {
                            if (error) {
                                console.log(error);
                            } else {
                                req.session.message = 'Agregado con Éxito';
                                res.redirect('/usuarios');
                            }
                        });
                    }
                });
            }
        }
    });
};

exports.update_usuarios = (req, res) => {
    const IDUSUARIO = req.body.IDUSUARIO;
    const NOMBREDEUSUARIO = req.body.NOMBREDEUSUARIO;
    const PASSWORD = req.body.PASSWORD;
    const TIPO = req.body.TIPO;
    const NOMBRE = req.body.NOMBRE;
    const APELLIDOPATERNO = req.body.APELLIDOPATERNO;
    const APELLIDOMATERNO = req.body.APELLIDOMATERNO;
    console.log(NOMBREDEUSUARIO, PASSWORD, TIPO, NOMBRE, APELLIDOPATERNO, APELLIDOMATERNO);
    connection.query('UPDATE PERSONA SET NOMBRE = ?, APELLIDOPATERNO = ?, APELLIDOMATERNO = ? WHERE IDPERSONA = ?', [NOMBRE, APELLIDOPATERNO, APELLIDOMATERNO, IDUSUARIO], (error, results) => {
        if (error) {
            console.log(error);
        } else {
            connection.query('UPDATE USUARIOS SET NOMBREDEUSUARIO = ?, PASSWORD = ?, TIPO = ? WHERE IDUSUARIO = ?', [NOMBREDEUSUARIO, PASSWORD, TIPO, IDUSUARIO], (error, results) => {
                if (error) {
                    console.log(error);
                } else {
                    req.session.message = 'Actualizado con Éxito';
                    res.redirect('/usuarios');
                }
            });
        }
    });
};







