const { Router } = require('express');
const connection = require('../database/db');

exports.venta_iniciada = (req, res) => {
    const IDMESA = req.body.IDMESA;
    const IDUSUARIO = req.body.IDUSUARIO;

    // Verifica si ya existe una venta activa para esta mesa
    connection.query(
        'SELECT IDVENTA FROM VENTA WHERE IDMESA = ? AND TIPO = 1',
        [IDMESA],
        (error, results) => {
            if (error) {
                console.log(error);
                req.session.message = 'Error al verificar la venta activa';
                res.redirect('/venta');
            } else if (results.length > 0) {
                // Si hay una venta activa, redirige a la venta existente
                const IDVENTA = results[0].IDVENTA;
                req.session.IDVENTA = IDVENTA;
                req.session.IDMESA = IDMESA;
                req.session.message = 'Ya existe una venta activa en esta mesa';
                res.redirect('/ventaIniciada');
            } else {
                // Si no hay venta activa, crea una nueva
                connection.query(
                    'INSERT INTO VENTA SET IDMESA = ?, TOTAL = ?, ESTADO = ?, IDUSUARIO = ?, FECHA = NOW(), TIPO = ?',
                    [IDMESA, 0, 1, IDUSUARIO, 1],
                    (error, results) => {
                        if (error) {
                            console.log(error);
                            req.session.message = 'Error al iniciar la venta';
                            res.redirect('/venta');
                        } else {
                            const IDVENTA = results.insertId;
                            req.session.IDVENTA = IDVENTA;
                            req.session.IDMESA = IDMESA;
                            req.session.message = 'Venta iniciada con éxito';
                            res.redirect('/ventaIniciada');
                        }
                    }
                );
            }
        }
    );
};


exports.save_ventapostres = (req, res) => {
    const IDVENTA = req.session.IDVENTA; // Obtiene el IDVENTA de la sesión
    const IDPOSTRES = req.body.IDPOSTRES;
    const CANTIDAD = parseInt(req.body.CANTIDAD, 10);

    console.log(IDVENTA, IDPOSTRES, CANTIDAD);

    // Verificar si se recibió una cantidad válida
    if (!CANTIDAD || CANTIDAD <= 0) {
        req.session.message = 'Cantidad no válida';
        return res.redirect(`/ventaIniciada?id=${IDVENTA}`);
    }

    // Consulta para verificar si el postre ya existe en VENTA_POSTRES para esta venta
    const checkQuery = 'SELECT CANTIDAD FROM VENTA_POSTRES WHERE IDVENTA = ? AND IDPOSTRES = ?';

    connection.query(checkQuery, [IDVENTA, IDPOSTRES], (error, results) => {
        if (error) {
            console.error('Error al verificar el postre:', error);
            req.session.message = 'Error al verificar el postre';
            return res.redirect(`/ventaIniciada?id=${IDVENTA}`);
        }

        if (results.length > 0) {
            // Si ya existe, actualiza la cantidad sumando el valor de CANTIDAD
            const newQuantity = results[0].CANTIDAD + CANTIDAD;
            const updateQuery = 'UPDATE VENTA_POSTRES SET CANTIDAD = ? WHERE IDVENTA = ? AND IDPOSTRES = ?';

            connection.query(updateQuery, [newQuantity, IDVENTA, IDPOSTRES], (error) => {
                if (error) {
                    console.error('Error al actualizar el postre:', error);
                    req.session.message = 'Error al actualizar el postre';
                    return res.redirect(`/ventaIniciada?id=${IDVENTA}`);
                }

                req.session.message = 'Cantidad de postre actualizada con éxito';
                res.redirect(`/ventaIniciada?id=${IDVENTA}`);
            });
        } else {
            // Si no existe, inserta un nuevo registro
            const insertQuery = 'INSERT INTO VENTA_POSTRES (IDVENTA, IDPOSTRES, CANTIDAD) VALUES (?, ?, ?)';

            connection.query(insertQuery, [IDVENTA, IDPOSTRES, CANTIDAD], (error) => {
                if (error) {
                    console.error('Error al guardar el postre:', error);
                    req.session.message = 'Error al guardar el postre';
                    return res.redirect(`/ventaIniciada?id=${IDVENTA}`);
                }

                req.session.message = 'Postre agregado con éxito';
                res.redirect(`/ventaIniciada?id=${IDVENTA}`);
            });
        }
    });
};


exports.save_ventabebidas = (req, res) => {
    const IDVENTA = req.session.IDVENTA; // Obtiene el IDVENTA de la sesión
    const IDBEBIDAS = req.body.IDBEBIDAS;
    const CANTIDAD = parseInt(req.body.CANTIDAD, 10);

    console.log(IDVENTA, IDBEBIDAS, CANTIDAD);

    // Verificar si se recibió una cantidad válida
    if (!CANTIDAD || CANTIDAD <= 0) {
        req.session.message = 'Cantidad no válida';
        return res.redirect(`/ventaIniciada?id=${IDVENTA}`);
    }

    // Consulta para verificar si la bebida ya existe en VENTA_BEBIDAS para esta venta
    const checkQuery = 'SELECT CANTIDAD FROM VENTA_BEBIDAS WHERE IDVENTA = ? AND IDBEBIDAS = ?';

    connection.query(checkQuery, [IDVENTA, IDBEBIDAS], (error, results) => {
        if (error) {
            console.error('Error al verificar la bebida:', error);
            req.session.message = 'Error al verificar la bebida';
            return res.redirect(`/ventaIniciada?id=${IDVENTA}`);
        }

        if (results.length > 0) {
            // Si ya existe, actualiza la cantidad sumando el valor de CANTIDAD
            const newQuantity = results[0].CANTIDAD + CANTIDAD;
            const updateQuery = 'UPDATE VENTA_BEBIDAS SET CANTIDAD = ? WHERE IDVENTA = ? AND IDBEBIDAS = ?';

            connection.query(updateQuery, [newQuantity, IDVENTA, IDBEBIDAS], (error) => {
                if (error) {
                    console.error('Error al actualizar la bebida:', error);
                    req.session.message = 'Error al actualizar la bebida';
                    return res.redirect(`/ventaIniciada?id=${IDVENTA}`);
                }

                req.session.message = 'Cantidad actualizada con éxito';
                res.redirect(`/ventaIniciada?id=${IDVENTA}`);
            });
        } else {
            // Si no existe, inserta un nuevo registro
            const insertQuery = 'INSERT INTO VENTA_BEBIDAS (IDVENTA, IDBEBIDAS, CANTIDAD) VALUES (?, ?, ?)';

            connection.query(insertQuery, [IDVENTA, IDBEBIDAS, CANTIDAD], (error) => {
                if (error) {
                    console.error('Error al guardar la bebida:', error);
                    req.session.message = 'Error al guardar la bebida';
                    return res.redirect(`/ventaIniciada?id=${IDVENTA}`);
                }

                req.session.message = 'Bebida agregada con éxito';
                res.redirect(`/ventaIniciada?id=${IDVENTA}`);
            });
        }
    });
};


exports.update_ventapostres = (req, res) => {
    const IDVENTA = req.session.IDVENTA;
    const IDPOSTRES = req.body.IDPOSTRES;
    const CANTIDAD = req.body.CANTIDAD;
    console.log(IDVENTA, IDPOSTRES, CANTIDAD);

    // Editar VENTA_POSTRES en lugar de VENTA_BEBIDAS
    connection.query('UPDATE VENTA_POSTRES SET CANTIDAD = ? WHERE IDPOSTRES = ? AND IDVENTA = ?', [CANTIDAD, IDPOSTRES, IDVENTA], (error, results) => {
        if (error) {
            console.log(error);
        } else {
            req.session.message = 'Actualizado con Éxito';
            res.redirect(`/ventaIniciada?id=${IDVENTA}`);
        }
    });
};

exports.update_ventabebidas = (req, res) => {
    const IDVENTA = req.session.IDVENTA;
    const IDBEBIDAS = req.body.IDBEBIDAS;
    // const NOMBRE = req.body.NOMBREPOSTRE;
    const CANTIDAD = req.body.CANTIDAD;
    console.log(IDVENTA, IDBEBIDAS, CANTIDAD)

    //FALTA EDITAR VENTA_BEBIDAS
    connection.query('UPDATE VENTA_BEBIDAS SET CANTIDAD = ? WHERE IDBEBIDAS = ? AND IDVENTA = ?', [CANTIDAD, IDBEBIDAS, IDVENTA], (error, results) => {
        if (error) {
            console.log(error);
        } else {
            req.session.message = 'Actualizado con Éxito';
            res.redirect(`/ventaIniciada?id=${IDVENTA}`);
        }
    });
};

exports.finalizar_venta = (req, res) => {
    const IDVENTA = req.session.IDVENTA;
    const TOTAL = req.body.TOTAL;

    console.log('IDVENTA:', IDVENTA);
    console.log('TOTAL:', TOTAL);

    // Verificar si hay un registro de CONTROLCAJA para la fecha actual y si la caja está abierta
    connection.query('SELECT * FROM CONTROLCAJA WHERE FECHA = CURDATE() AND ESTADO = 1', (error, results) => {
        if (error) {
            console.log(error);
            req.session.message = 'Error al verificar el estado de la caja';
            return res.redirect('/venta');
        }

        if (results.length === 0) {
            // No hay registro de CONTROLCAJA para la fecha actual o la caja no está abierta
            req.session.message = 'Es necesario abrir caja primero';
            return res.redirect('/dashboard');
        }

        // Verificar si hay productos en la venta actual
        connection.query('SELECT COUNT(*) AS count FROM venta_bebidas WHERE IDVENTA = ? UNION ALL SELECT COUNT(*) AS count FROM venta_postres WHERE IDVENTA = ?', [IDVENTA, IDVENTA], (error, results) => {
            if (error) {
                console.log(error);
                req.session.message = 'Error al verificar los productos de la venta';
                return res.redirect('/venta');
            }

            const totalProducts = results.reduce((sum, row) => sum + row.count, 0);

            if (totalProducts === 0) {
                // No hay productos en la venta actual
                req.session.message = 'No se puede finalizar la venta ya que no hay productos dentro de ella';
                return res.redirect('/venta');
            }

            // Actualizar la venta en la base de datos
            connection.query('UPDATE VENTA SET TOTAL = ?, ESTADO = 2 WHERE IDVENTA = ?', [TOTAL, IDVENTA], (error, results) => {
                if (error) {
                    console.log(error);
                    req.session.message = 'Error al finalizar la venta';
                    return res.redirect('/venta');
                }

                // Actualizar el monto actual y el total de caja en la tabla CONTROLCAJA
                connection.query('UPDATE CONTROLCAJA SET MONTOACTUAL = MONTOACTUAL + ?, TOTALCAJA = TOTALCAJA + ? WHERE FECHA = CURDATE()', [TOTAL, TOTAL], (error, results) => {
                    if (error) {
                        console.log(error);
                        req.session.message = 'Error al actualizar el monto actual y el total de la caja';
                        return res.redirect('/venta');
                    }

                    req.session.message = 'Venta finalizada con éxito y monto actual de la caja actualizado';
                    return res.redirect('/venta');
                });
            });
        });
    });
};