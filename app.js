////////////////////////////////////////////////////////////////////////////////////////////////////////
//INVOCAMOS A EXPRESS
const express = require('express');
const app = express();

//PONEMOS URL ENCODED PARA CAPTURAR DATOS DEL FORMULARIO
app.use(express.urlencoded({ extended: false }));
app.use(express.json());//además le decimos a express que vamos a usar json

// INVOCAMOS A DOTENV
const dotenv = require('dotenv');
dotenv.config({ path: './env/.env' });

//PONEMOS EL DIRECTORIO PUBLIC
app.use('/resources', express.static('public'));
app.use('/resources', express.static(__dirname + '/public'));

//ESTABLECEMOS EL MOTOR DE PLANTILLAS EJS
app.set('view engine', 'ejs');

//INVOCAMOS A BCRYPTJS
const bcryptjs = require('bcryptjs');

//VAR DE SESSION
const session = require('express-session');

//////////////////////////////////////////////

//COOKIES 

const MySQLStore = require('express-mysql-session')(session);
const options = {
    host: process.env.DB_HOST,
    port: 3306,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_DATABASE
};

const sessionStore = new MySQLStore(options);

app.use(session({
    secret: 'secret',
    resave: false, // Solo guarda la sesión si se modifica
    saveUninitialized: false, // No guarda sesiones no inicializadas
    store: sessionStore,
    cookie: {
        maxAge: 24 * 60 * 60 * 1000, // 1 día de duración en milisegundos
        httpOnly: true, // La cookie solo es accesible desde HTTP(S)
        secure: process.env.NODE_ENV === 'production' // Solo en producción para HTTPS
    }
}));

/////////////////////////////////////////////////
//INVOCAMOS A MYSQL
const connection = require('./database/db');

//MULTER
const fs = require('fs');
const path = require('path');
const multer = require('multer');

// Middleware para servir archivos estáticos
app.use('/resources', express.static('public'));

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, 'public/Imagenes_Productos'); // Ruta donde se guardarán las imágenes
    },
    filename: function (req, file, cb) {
        const filePath = path.join('public/Imagenes_Productos', file.originalname);
        fs.access(filePath, fs.constants.F_OK, (err) => {
            let filename;
            if (err) {
                filename = file.originalname; // El archivo no existe, usa el nombre original
            } else {
                const fileExtension = path.extname(file.originalname);
                const basename = path.basename(file.originalname, fileExtension);
                filename = `${basename}-${Date.now()}${fileExtension}`; // Agregar un timestamp al nombre del archivo
            }
            cb(null, filename);
        });
    }
});

const upload = multer({ storage });
//MENU DIGITAL/////////////////////////////////////////////////////////////
app.get('/', (req, res) => {
    connection.query('SELECT * FROM CATEGORIAS WHERE ESTADO = 1', (error, categorias) => {
        if (error) {
            throw error;
        }
        connection.query('SELECT * FROM BEBIDAS WHERE ESTADO = 1', (error, bebidas) => {
            if (error) {
                throw error;
            }
            connection.query('SELECT * FROM POSTRES WHERE ESTADO = 1', (error, postres) => {
                if (error) {
                    throw error;
                }
                res.render('index', {
                    title: 'Menu Camelina',
                    categorias: categorias,
                    bebidas: bebidas,
                    postres: postres
                });
            });
        });
    });
});

///////////////////////////////////////////
//LOGIN/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
app.get('/login', (req, res) => {
    res.render('login');
});

function checkAuth(req, res, next) {
    if (req.session && req.session.loggedin) {
        next(); // Continúa a la ruta si está autenticado
    } else {
        res.redirect('/login'); // Redirige al login si no está autenticado
    }
}

app.post('/auth', async (req, res) => {
    const user = req.body.user;
    const password = req.body.password;
    if (user && password) {
        connection.query('SELECT * FROM USUARIOS WHERE NOMBREDEUSUARIO = ? AND ESTADO = 1', [user], async (error, results) => {
            if (results.length == 0 || password !== results[0].PASSWORD) {
                // res.send('Usuario o contraseña incorrecta');
                res.render('login', {
                    alert: true,
                    alertTitle: "Error",
                    alertMessage: "Usuario y/o contraseña incorrectas",
                    alertIcon: "error",
                    showConfirmButton: true,
                    timer: false,
                    ruta: 'login'
                })
            } else {
                // res.send('Bienvenido');
                req.session.loggedin = true;
                req.session.name = results[0].NOMBREDEUSUARIO;
                req.session.userId = results[0].IDUSUARIO;
                res.render('login', {
                    alert: true,
                    alertTitle: "Conexion Exitosa",
                    alertMessage: "Bienvenido!",
                    alertIcon: "success",
                    showConfirmButton: false,
                    timer: 1500,
                    ruta: 'dashboard'
                })
            }
        });
    } else {
        res.send("POR FAVOR COMPLETA TODOS LOS CAMPOS")
    }
});
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//DASHBOARD/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
const crudCaja = require('./controllers/crudCaja');

app.get('/dashboard', checkAuth, crudCaja.verificarCaja, (req, res) => {
    if (req.session.loggedin) {
        connection.query(`
            SELECT BEBIDAS.NOMBRE AS NOMBRE, SUM(VENTA_BEBIDAS.CANTIDAD) AS CANTIDAD_TOTAL
            FROM VENTA_BEBIDAS
            JOIN VENTA ON VENTA.IDVENTA = VENTA_BEBIDAS.IDVENTA
            JOIN BEBIDAS ON BEBIDAS.IDBEBIDAS = VENTA_BEBIDAS.IDBEBIDAS
            WHERE YEAR(VENTA.FECHA) = YEAR(CURRENT_DATE())
            GROUP BY BEBIDAS.NOMBRE
            ORDER BY CANTIDAD_TOTAL DESC
            LIMIT 3`, (error, bebidasVendidas) => {
            if (error) {
                throw error;
            } else {
                connection.query(`
                    SELECT POSTRES.NOMBRE AS NOMBRE, SUM(VENTA_POSTRES.CANTIDAD) AS CANTIDAD_TOTAL
                    FROM VENTA_POSTRES
                    JOIN VENTA ON VENTA.IDVENTA = VENTA_POSTRES.IDVENTA
                    JOIN POSTRES ON POSTRES.IDPOSTRES = VENTA_POSTRES.IDPOSTRES
                    WHERE YEAR(VENTA.FECHA) = YEAR(CURRENT_DATE())
                    GROUP BY POSTRES.NOMBRE
                    ORDER BY CANTIDAD_TOTAL DESC
                    LIMIT 3`, (error, postresVendidos) => {
                    if (error) {
                        throw error;
                    } else {
                        // Consultar ventas por mes del año actual
                        connection.query(`
                            SELECT MONTH(FECHA) AS MES, SUM(TOTALCAJA) AS TOTAL_VENTAS
                            FROM CONTROLCAJA
                            WHERE YEAR(FECHA) = YEAR(CURRENT_DATE())
                            GROUP BY MONTH(FECHA)
                            ORDER BY MES`, (error, ventasMensuales) => {
                            if (error) {
                                throw error;
                            } else {
                                // Consultar gastos por mes del año actual
                                connection.query(`
                                    SELECT MONTH(FECHA) AS MES, SUM(MONTO) AS TOTAL_GASTOS
                                    FROM GASTOS
                                    WHERE YEAR(FECHA) = YEAR(CURRENT_DATE())
                                    GROUP BY MONTH(FECHA)
                                    ORDER BY MES`, (error, gastosMensuales) => {
                                    if (error) {
                                        throw error;
                                    } else {
                                        res.render('layout', {
                                            title: 'Dashboard',
                                            body: 'dashboard',
                                            login: true,
                                            name: req.session.name,
                                            userId: req.session.userId,
                                            message: req.session.message,
                                            cajaAbierta: req.session.cajaAbierta,
                                            cajaCerrada: req.session.cajaCerrada,
                                            controlCaja: req.session.controlCaja,
                                            postresVendidos: postresVendidos,
                                            bebidasVendidas: bebidasVendidas,
                                            ventasMensuales: ventasMensuales,
                                            gastosMensuales: gastosMensuales
                                        });
                                    }
                                });
                            }
                        });
                    }
                });
            }
        });
    } else {
        res.render('layout', {
            title: 'Dashboard',
            body: 'dashboard',
            login: false,
            name: 'Debe iniciar sesión'
        });
    }
});

app.post('/abrirCaja', checkAuth, crudCaja.abrirCaja);
app.post('/reabrirCaja', checkAuth, crudCaja.reabrirCaja);
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//USUARIOS/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
app.get("/usuarios",checkAuth, (req, res) => {
    connection.query('SELECT * FROM VistaUsuariosActivos', (error, usuarios) => {
        if (error) {
            throw error;
        }
        const message = req.session.message;
        req.session.message = null;
        res.render('layout', {
            title: 'Usuarios',
            body: 'USUARIOS/usuarios',
            usuarios: usuarios,
            message: message
        });
    });
});

app.get('/createUsuarios',checkAuth, (req, res) => {
    res.render('layout', {
        title: 'Crear usuarios',
        body: 'USUARIOS/createUsuarios',
    });
});

app.get('/editUsuarios/:IDUSUARIOS',checkAuth, (req, res) => {
    const IDUSUARIOS = req.params.IDUSUARIOS;
    connection.query('SELECT USUARIOS.*, PERSONA.* FROM USUARIOS INNER JOIN PERSONA ON USUARIOS.IDPERSONA = PERSONA.IDPERSONA WHERE USUARIOS.IDUSUARIO = ?', [IDUSUARIOS], (error, usuarios) => {
        if (error) {
            throw error
        } else {
            res.render('layout', {
                title: 'Editar Usuarios',
                body: 'USUARIOS/editUsuarios',
                usuarios: usuarios[0],
            });
        };
    }
    );
});

app.get('/deleteUsuarios/:IDUSUARIO',checkAuth, (req, res) => {
    const IDUSUARIO = req.params.IDUSUARIO;
    console.log(IDUSUARIO);
    connection.query('UPDATE USUARIOS SET ESTADO = 0 WHERE IDUSUARIO = ?', [IDUSUARIO], (error, results) => {
        if (error) {
            console.log(error);
            return res.status(500).send('Error en la base de datos');
        } else {
            req.session.message = 'Eliminado con Éxito';
            res.redirect('/usuarios');
        }
    });
});

const crudUsuarios = require('./controllers/crudUsuarios');
app.post('/save_usuarios', crudUsuarios.save_usuarios);
app.post('/update_usuarios', crudUsuarios.update_usuarios);
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//INDEX///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

app.get('/', (req, res) => {
    res.render('index'); // Renderiza solo la vista de index
});
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//BEBIDAS/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
app.get('/bebidas', checkAuth,(req, res) => {
    connection.query('SELECT * FROM vista_bebidas', (error, bebidas) => {
        if (error) {
            throw error;
        }
        const message = req.session.message;
        req.session.message = null;
        res.render('layout', {
            title: 'Bebidas',
            body: 'BEBIDAS/bebidas',
            bebidas: bebidas,
            message: message
        });
    });
});

app.get('/createBebidas', checkAuth,(req, res) => {
    connection.query('SELECT * FROM CATEGORIAS WHERE ESTADO = 1', (error, categorias) => {
        if (error) {
            throw error;
        }
        res.render('layout', {
            title: 'Crear Bebida',
            body: 'BEBIDAS/createBebidas',
            categorias: categorias
        });
    });
});

app.get('/editBebidas/:IDBEBIDAS', checkAuth,(req, res) => {
    const IDBEBIDAS = req.params.IDBEBIDAS;

    connection.query("SELECT * FROM BEBIDAS WHERE IDBEBIDAS = ?", [IDBEBIDAS], (error, bebidas) => {
        if (error) {
            throw error;
        } else {
            connection.query("SELECT * FROM CATEGORIAS WHERE ESTADO = 1", (error, categorias) => {
                if (error) {
                    throw error;
                } else {
                    res.render('layout', {
                        title: 'Editar Bebida',
                        body: 'BEBIDAS/editBebidas',
                        bebidas: bebidas[0],
                        categorias: categorias,
                    });
                }
            });
        }
    });
});

app.get('/deleteBebidas/:IDBEBIDAS', checkAuth,(req, res) => {
    const IDBEBIDAS = req.params.IDBEBIDAS;
    console.log(IDBEBIDAS);
    connection.query('UPDATE BEBIDAS SET ESTADO = 0 WHERE IDBEBIDAS = ?', [IDBEBIDAS], (error, results) => {
        if (error) {
            console.log(error);
            return res.status(500).send('Error en la base de datos');
        } else {
            req.session.message = 'Eliminado con Éxito';
            res.redirect('/bebidas');
        }
    });
});

const crudBebidas = require('./controllers/crudBebidas');
const { title } = require('process');
app.post('/save_bebidas', upload.single('FOTO'), crudBebidas.save_bebidas);
app.post('/update_bebidas', upload.single('FOTO'), crudBebidas.update_bebidas);
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//CATEGORIAS///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
app.get('/categorias', checkAuth,(req, res) => {
    connection.query('SELECT * FROM CATEGORIAS WHERE ESTADO = 1', (error, categorias) => {
        if (error) {
            throw error;
        }
        const message = req.session.message;
        req.session.message = null;
        res.render('layout', {
            title: 'Categorias',
            body: 'CATEGORIAS/categorias',
            categorias: categorias,
            message: message
        });
    });
});

app.get('/createCategorias', checkAuth,(req, res) => {
    res.render('layout', {
        title: 'Crear Categoria',
        body: 'CATEGORIAS/createCategorias',
    });
});

app.get('/editCategorias/:IDCATEGORIA', checkAuth,(req, res) => {
    const IDCATEGORIA = req.params.IDCATEGORIA;
    connection.query('SELECT * FROM CATEGORIAS WHERE IDCATEGORIA = ?', [IDCATEGORIA], (error, categorias) => {
        if (error) {
            throw error
        } else {
            res.render('layout', {
                title: 'Editar Usuarios',
                body: 'CATEGORIAS/editCategorias',
                categorias: categorias[0],
            });
        };
    }
    );
});

app.get('/deleteCategorias/:IDCATEGORIA',checkAuth, (req, res) => {
    const IDCATEGORIA = req.params.IDCATEGORIA;
    console.log(IDCATEGORIA);
    connection.query('UPDATE CATEGORIAS SET ESTADO = 0 WHERE IDCATEGORIA = ?', [IDCATEGORIA], (error, results) => {
        if (error) {
            console.log(error);
            return res.status(500).send('Error en la base de datos');
        } else {
            req.session.message = 'Eliminado con Éxito';
            res.redirect('/categorias');
        }
    });
});

const crudCategorias = require('./controllers/crudCategorias');
app.post('/save_categorias', crudCategorias.save_categorias);
app.post('/update_categorias', crudCategorias.update_categorias);
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//POSTRES//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
app.get('/postres', checkAuth,(req, res) => {
    connection.query('SELECT * FROM POSTRES', (error, postres) => {
        if (error) {
            throw error;
        }
        const message = req.session.message;
        req.session.message = null;
        res.render('layout', {
            title: 'Postres',
            body: 'POSTRES/postres',
            postres: postres,
            message: message
        });
    });
});

app.get('/createPostres',checkAuth, (req, res) => {
    res.render('layout', {
        title: 'Crear Postres',
        body: 'POSTRES/createPostres',
    });
});

app.get('/editPostres/:IDPOSTRES', checkAuth,(req, res) => {
    const IDPOSTRES = req.params.IDPOSTRES;

    connection.query("SELECT * FROM POSTRES WHERE IDPOSTRES = ?", [IDPOSTRES], (error, postres) => {
        if (error) {
            throw error;
        } else {
            res.render('layout', {
                title: 'Editar Postres',
                body: 'POSTRES/editPostres',
                postres: postres[0],
            });
        }
    });
});

app.get('/deletePostres/:IDPOSTRES',checkAuth, (req, res) => {
    const IDPOSTRES = req.params.IDPOSTRES;
    console.log(IDPOSTRES);
    connection.query('UPDATE POSTRES SET ESTADO = 0 WHERE IDPOSTRES = ?', [IDPOSTRES], (error, results) => {
        if (error) {
            console.log(error);
            return res.status(500).send('Error en la base de datos');
        } else {
            req.session.message = 'Eliminado con Éxito';
            res.redirect('/postres');
        }
    });
});

const crudPostres = require('./controllers/crudPostres');
app.post('/save_postres', upload.single('FOTO'), crudPostres.save_postres);
app.post('/update_postres', upload.single('FOTO'), crudPostres.update_postres);

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//MESAS//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
app.get('/mesas/:IDAREA?', checkAuth,(req, res) => {
    const IDAREA = req.params.IDAREA; // Obtener el idArea de la URL, si existe
    let query = 'SELECT * FROM MESAS WHERE ESTADO = 1';
    let queryParams = [];

    // Si hay un idArea, modificar la consulta
    if (IDAREA) {
        query += ' AND IDAREA = ?';
        queryParams.push(IDAREA);
    }

    connection.query(query, queryParams, (error, mesas) => {
        if (error) {
            throw error;
        } else {
            connection.query('SELECT * FROM AREAS WHERE ESTADO = 1', (error, areas) => {
                if (error) {
                    throw error;
                } else {
                    const message = req.session.message;
                    req.session.message = null;
                    res.render('layout', {
                        title: 'Mesas',
                        body: 'MESAS/mesas',
                        mesas: mesas,
                        areas: areas,
                        message: message
                    });
                }
            });
        }
    });
});

app.get('/createMesas', checkAuth,(req, res) => {
    connection.query('SELECT * FROM AREAS WHERE ESTADO = 1', (error, areas) => {
        if (error) {
            throw error;
        }
        res.render('layout', {
            title: 'Crear Mesas',
            body: 'MESAS/createMesas',
            areas: areas
        });
    });
});

app.get('/editMesas/:IDMESA',checkAuth, (req, res) => {
    const IDMESA = req.params.IDMESA;
    connection.query('SELECT * FROM MESAS WHERE IDMESA = ?', [IDMESA], (error, mesas) => {
        if (error) {
            throw error
        }
        connection.query('SELECT * FROM AREAS WHERE ESTADO = 1', (error, areas) => {
            if (error) {
                throw error
            }
            res.render('layout', {
                title: 'Editar Mesas',
                body: 'MESAS/editMesas',
                mesas: mesas[0],
                areas: areas
            });
        });
    });
});

app.get('/deleteMesas/:IDMESA',checkAuth, (req, res) => {
    const IDMESA = req.params.IDMESA;
    console.log(IDMESA);
    connection.query('UPDATE MESAS SET ESTADO = 0 WHERE IDMESA = ?', [IDMESA], (error, results) => {
        if (error) {
            console.log(error);
            return res.status(500).send('Error en la base de datos');
        } else {
            req.session.message = 'Eliminado con Éxito';
            res.redirect('/mesas');
        }
    });
});

const crudMesas = require('./controllers/crudMesas');
app.post('/save_mesas', crudMesas.save_mesas);
app.post('/update_mesas', crudMesas.update_mesas);


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//AREAS/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
app.get('/areas',checkAuth, (req, res) => {
    connection.query('SELECT * FROM AREAS WHERE ESTADO = 1', (error, areas) => {
        if (error) {
            throw error;
        }
        const message = req.session.message;
        req.session.message = null;
        res.render('layout', {
            title: 'Areas',
            body: 'AREAS/areas',
            areas: areas,
            message: message
        });
    });
});

app.get('/createAreas', checkAuth,(req, res) => {
    res.render('layout', {
        title: 'Crear Areas',
        body: 'AREAS/createAreas',
    });
});

app.get('/editAreas/:IDAREA',checkAuth, (req, res) => {
    const IDAREA = req.params.IDAREA;
    connection.query('SELECT * FROM AREAS WHERE IDAREA = ?', [IDAREA], (error, areas) => {
        if (error) {
            throw error
        } else {
            res.render('layout', {
                title: 'Editar Area',
                body: 'AREAS/editAreas',
                areas: areas[0],
            });
        };
    }
    );
});

app.get('/deleteAreas/:IDAREA',checkAuth, (req, res) => {
    const IDAREA = req.params.IDAREA;
    console.log(IDAREA);
    connection.query('UPDATE AREAS SET ESTADO = 0 WHERE IDAREA = ?', [IDAREA], (error, results) => {
        if (error) {
            console.log(error);
            return res.status(500).send('Error en la base de datos');
        } else {
            req.session.message = 'Eliminado con Éxito';
            res.redirect('/areas');
        }
    });
});

const crudAreas = require('./controllers/crudAreas');
app.post('/save_areas', crudAreas.save_areas);
app.post('/update_areas', crudAreas.update_areas);
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//VENTA/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
app.get('/venta/:IDAREA?', checkAuth, (req, res) => {
    const IDAREA = req.params.IDAREA; // Obtener el idArea de la URL, si existe
    let query = `
        SELECT MESAS.*, 
               CASE 
                   WHEN VENTA.ESTADO = 1 THEN 0 
                   ELSE 1 
               END AS DISPONIBLE
        FROM MESAS
        LEFT JOIN VENTA ON MESAS.IDMESA = VENTA.IDMESA AND VENTA.ESTADO = 1
        WHERE MESAS.ESTADO = 1
    `;
    let queryParams = [];

    // Si hay un idArea, modificar la consulta
    if (IDAREA) {
        query += ' AND MESAS.IDAREA = ?';
        queryParams.push(IDAREA);
    }

    connection.query(query, queryParams, (error, mesas) => {
        if (error) {
            throw error;
        } else {
            connection.query('SELECT * FROM AREAS WHERE ESTADO = 1', (error, areas) => {
                if (error) {
                    throw error;
                } else {
                    const message = req.session.message;
                    req.session.message = null;
                    res.render('layout', {
                        title: 'Venta',
                        body: 'VENTA/venta',
                        mesas: mesas,
                        areas: areas,
                        message: message,
                        userId: req.session.userId
                    });
                }
            });
        }
    });
});

const crudVentaIniciada = require('./controllers/crudVentaIniciada');
app.post('/venta_iniciada', crudVentaIniciada.venta_iniciada);

//
app.get('/ventaIniciada', checkAuth, (req, res) => {
    const IDVENTA = req.session.IDVENTA;
    const IDMESA = req.session.IDMESA;
    console.log('IDMESA:', IDMESA);
    console.log('IDVENTA:', IDVENTA);

    // Consulta para obtener la venta por IDVENTA
    connection.query('SELECT * FROM VENTA WHERE IDVENTA = ? AND TIPO = 1', [IDVENTA], (error, venta) => {
        if (error) throw error;
        else {
            // Consulta para obtener la mesa por IDMESA
            connection.query('SELECT * FROM MESAS WHERE IDMESA = ?', [IDMESA], (error, mesas) => {
                if (error) throw error;
                else {
                    // Consulta para obtener las bebidas activas
                    connection.query('SELECT * FROM BEBIDAS WHERE ESTADO = 1', (error, bebidas) => {
                        if (error) throw error;
                        else {
                            // Consulta para obtener los postres activos
                            connection.query('SELECT * FROM POSTRES WHERE ESTADO = 1', (error, postres) => {
                                if (error) throw error;
                                else {
                                    // Obtener postres relacionados con la venta
                                    connection.query(`
                                        SELECT VP.IDPOSTRES, P.NOMBRE, P.PRECIO, VP.CANTIDAD, P.FOTO
                                        FROM VENTA_POSTRES VP
                                        JOIN POSTRES P ON VP.IDPOSTRES = P.IDPOSTRES
                                        WHERE VP.IDVENTA = ?
                                    `, [IDVENTA], (error, venta_POSTRES) => {
                                        if (error) throw error;
                                        else {
                                            // Obtener bebidas relacionadas con la venta
                                            connection.query(`
                                                SELECT VB.IDBEBIDAS, B.NOMBRE, B.PRECIO, VB.CANTIDAD, B.FOTO
                                                FROM VENTA_BEBIDAS VB
                                                JOIN BEBIDAS B ON VB.IDBEBIDAS = B.IDBEBIDAS
                                                WHERE VB.IDVENTA = ?
                                            `, [IDVENTA], (error, venta_bebidas) => {
                                                if (error) throw error;
                                                else {
                                                    const message = req.session.message;
                                                    req.session.message = null;
                                                    res.render('layout', {
                                                        title: 'Venta Iniciada',
                                                        body: 'VENTA/ventaIniciada',
                                                        bebidas: bebidas,
                                                        postres: postres,
                                                        venta_POSTRES: venta_POSTRES,
                                                        message: message,
                                                        venta: venta,
                                                        mesas: mesas,
                                                        venta_bebidas: venta_bebidas,
                                                        IDVENTA: IDVENTA
                                                    });
                                                }
                                            });
                                        }
                                    });
                                }
                            });
                        }
                    });
                }
            });
        }
    });
});

app.get('/editVentaBebidasyPostres', checkAuth, (req, res) => {

    const IDVENTA = req.session.IDVENTA;
    console.log('IDVENTA:', IDVENTA);

    // Consulta para obtener la venta por IDVENTA
    connection.query('SELECT * FROM VENTA WHERE IDVENTA = ? AND TIPO = 1', [IDVENTA], (error, venta) => {
        if (error) throw error;
        else {
            // Consulta para obtener las bebidas activas
            connection.query('SELECT * FROM BEBIDAS WHERE ESTADO = 1', (error, bebidas) => {
                if (error) throw error;
                else {
                    // Consulta para obtener los postres activos
                    connection.query('SELECT * FROM POSTRES WHERE ESTADO = 1', (error, postres) => {
                        if (error) throw error;
                        else {
                            // Obtener postres relacionados con la venta
                            connection.query(`
                                        SELECT VP.IDPOSTRES, P.NOMBRE, P.PRECIO, VP.CANTIDAD, P.FOTO
                                        FROM VENTA_POSTRES VP
                                        JOIN POSTRES P ON VP.IDPOSTRES = P.IDPOSTRES
                                        WHERE VP.IDVENTA = ?
                                    `, [IDVENTA], (error, venta_POSTRES) => {
                                if (error) throw error;
                                else {
                                    // Obtener bebidas relacionadas con la venta
                                    connection.query(`
                                                SELECT VB.IDBEBIDAS, B.NOMBRE, B.PRECIO, VB.CANTIDAD, B.FOTO
                                                FROM VENTA_BEBIDAS VB
                                                JOIN BEBIDAS B ON VB.IDBEBIDAS = B.IDBEBIDAS
                                                WHERE VB.IDVENTA = ?
                                            `, [IDVENTA], (error, venta_bebidas) => {
                                        if (error) throw error;
                                        else {
                                            const message = req.session.message;
                                            req.session.message = null;
                                            res.render('layout', {
                                                title: 'Venta Iniciada',
                                                body: 'VENTA/editVentaBebidasyPostres',
                                                bebidas: bebidas,
                                                postres: postres,
                                                venta_POSTRES: venta_POSTRES,
                                                message: message,
                                                venta: venta,
                                                venta_bebidas: venta_bebidas,
                                                IDVENTA: IDVENTA
                                            });
                                        }
                                    });
                                }
                            });
                        }
                    });
                }
            });
        }
    });
})

app.post('/save_ventapostres', crudVentaIniciada.save_ventapostres);
app.post('/save_ventabebidas', crudVentaIniciada.save_ventabebidas);
app.post('/update_ventapostres', crudVentaIniciada.update_ventapostres);
app.post('/update_ventabebidas', crudVentaIniciada.update_ventabebidas);

app.post('/finalizar_venta', crudVentaIniciada.finalizar_venta);

app.get('/deleteBebidasfromVenta/:IDBEBIDAS', checkAuth, (req, res) => {
    const IDVENTA = req.session.IDVENTA;
    const IDBEBIDAS = req.params.IDBEBIDAS;

    console.log(IDVENTA, IDBEBIDAS);
    connection.query("DELETE FROM VENTA_BEBIDAS WHERE IDBEBIDAS = ? AND IDVENTA = ?", [IDBEBIDAS, IDVENTA], (error, results) => {
        if (error) {
            console.error(error);
            res.status(500).send('Error al eliminar la bebida de la venta');
        } else {
            req.session.message = 'Bebida eliminada de la venta con éxito';
            res.redirect(`/ventaIniciada?id=${IDVENTA}`);
        }
    });
})

app.get('/deletePostresfromVenta/:IDPOSTRES', checkAuth, (req, res) => {
    const IDVENTA = req.session.IDVENTA;
    const IDPOSTRES = req.params.IDPOSTRES;

    console.log(IDVENTA, IDPOSTRES);
    connection.query("DELETE FROM VENTA_POSTRES WHERE IDPOSTRES = ? AND IDVENTA = ?", [IDPOSTRES, IDVENTA], (error, results) => {
        if (error) throw error;
        else {
            req.session.message = 'Postre eliminado de la venta con éxito';
            res.redirect(`/ventaIniciada?id=${IDVENTA}`);
        }
    });
});

//CONTROL DE GASTOS///////////////////////////////////////////////////////////////////////////////////////////////////////////////
app.get('/gastos',checkAuth, (req, res) => {
    connection.query('SELECT * FROM GASTOS WHERE ESTADO = 1', (error, gastos) => {
        if (error) {
            throw error;
        }
        const message = req.session.message;
        req.session.message = null;
        res.render('layout', {
            title: 'Gastos',
            body: 'CONTROL_GASTOS/gastos',
            gastos: gastos,
            message: message
        });
    });
});

app.get('/createGastos',checkAuth, (req, res) => {
    res.render('layout', {
        title: 'Crear Gastos',
        body: 'CONTROL_GASTOS/createGastos',
    });
});

app.get('/editGastos/:IDGASTOS',checkAuth, (req, res) => {
    const IDGASTOS = req.params.IDGASTOS;
    connection.query('SELECT * FROM GASTOS WHERE IDGASTOS = ?', [IDGASTOS], (error, gastos) => {
        if (error) {
            throw error
        } else {
            res.render('layout', {
                title: 'Editar Gasto',
                body: 'CONTROL_GASTOS/editGastos',
                gastos: gastos[0]
            });
        };
    }
    );
});

app.get('/deleteGastos/:IDGASTOS',checkAuth, (req, res) => {
    const IDGASTOS = req.params.IDGASTOS;
    console.log(IDGASTOS);

    // Obtener el monto del gasto antes de actualizar su estado
    connection.query('SELECT MONTO, ACCION FROM GASTOS WHERE IDGASTOS = ?', [IDGASTOS], (error, results) => {
        if (error) {
            console.log(error);
            return res.status(500).send('Error en la base de datos');
        }

        const MONTO = results[0].MONTO;
        const ACCION = results[0].ACCION;

        // Actualizar el estado del gasto a 0 (eliminado lógico)
        connection.query('UPDATE GASTOS SET ESTADO = 0 WHERE IDGASTOS = ?', [IDGASTOS], (error, results) => {
            if (error) {
                console.log(error);
                return res.status(500).send('Error en la base de datos');
            }

            if (ACCION === 1) {
                // Sumar el monto del gasto al monto actual y total de caja
                connection.query('UPDATE CONTROLCAJA SET MONTOACTUAL = MONTOACTUAL + ?, TOTALCAJA = TOTALCAJA + ? WHERE FECHA = CURDATE()', [MONTO, MONTO], (error, results) => {
                    if (error) {
                        console.log(error);
                        return res.status(500).send('Error en la base de datos');
                    }

                    req.session.message = 'Eliminado con Éxito y monto de la caja actualizado';
                    res.redirect('/gastos');
                });
            } else {
                req.session.message = 'Eliminado con Éxito';
                res.redirect('/gastos');
            }
        });
    });
});

const crudGastos = require('./controllers/crudGastos');
app.post('/save_gastos', crudGastos.save_gastos);
app.post('/update_gastos', crudGastos.update_gastos);
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//CONTROL DE CAJA///////////////////////////////////////////////////////////////////////////////////////////////////////////////
app.get('/caja', (req, res) => {
    connection.query('SELECT * FROM CONTROLCAJA WHERE FECHA = CURDATE()', (error, controlCaja) => {
        if (error) {
            throw error;
        }
        const message = req.session.message;
        req.session.message = null;
        const cajaAbierta = controlCaja.length > 0;
        res.render('layout', {
            title: 'Control de Caja',
            body: 'CAJA/caja',
            controlCaja: controlCaja[0],
            message: message,
            cajaAbierta: cajaAbierta
        });
    });
});

app.post('/cerrarCaja',checkAuth, crudCaja.cerrarCaja);

app.get('/historialCaja',checkAuth, (req, res) => {
    connection.query('SELECT * FROM CONTROLCAJA WHERE ESTADO = 2', (error, controlCaja) => {
        if (error) {
            throw error;
        }
        const message = req.session.message;
        req.session.message = null;
        res.render('layout', {
            title: 'Historial de Caja',
            body: 'CAJA/historialCaja',
            controlCaja: controlCaja,
            message: message
        });
    });
});

app.get('/deleteNotas/:IDCONTROLCAJA', checkAuth, (req, res) => {
    const IDCONTROLCAJA = req.params.IDCONTROLCAJA;

    console.log(IDCONTROLCAJA);
    connection.query("UPDATE CONTROLCAJA SET NOTAS = NULL WHERE IDCONTROLCAJA = ?", [IDCONTROLCAJA], (error, results) => {
        if (error) throw error;
        else {
            req.session.message = 'Observación eliminada con éxito';
            res.redirect('/historialCaja');
        }
    });
});

app.post('/save_notas', crudCaja.save_notas);

//
app.get('/reportes', checkAuth, (req, res) => {
    connection.query(`
       SELECT 
    b.NOMBRE AS Bebida,
    SUM(vb.CANTIDAD) AS Cantidad_Vendida,
    c.NOMBRE AS Categoria,
    MAX(v.FECHA) AS FECHA
FROM 
    venta_bebidas vb
JOIN 
    BEBIDAS b ON vb.IDBEBIDAS = b.IDBEBIDAS
JOIN 
    CATEGORIAS c ON b.IDCATEGORIA = c.IDCATEGORIA
JOIN
    VENTA v ON vb.IDVENTA = v.IDVENTA
GROUP BY 
    b.NOMBRE, c.NOMBRE;
       `, (error, bebidasVendidas) => {
        if (error) {
            throw error;
        } else {
            connection.query(`
SELECT 
    p.NOMBRE AS Postre,
    SUM(vp.CANTIDAD) AS Cantidad_Vendida,
    MAX(v.FECHA) AS FECHA
FROM 
    venta_postres vp
JOIN 
    POSTRES p ON vp.IDPOSTRES = p.IDPOSTRES
JOIN
    VENTA v ON vp.IDVENTA = v.IDVENTA
GROUP BY 
    p.NOMBRE;
                `, (error, postresVendidos) => {
                if (error) {
                    throw error;
                } else {
                    // Consultar ventas por mes del año actual
                    connection.query(`
SELECT 
    *
FROM 
    HISTORIAL_VENTAS;
                        `, (error, ventasMensuales) => {
                        if (error) {
                            throw error;
                        } else {
                            // Consultar gastos por mes del año actual
                            connection.query(`
SELECT 
    *
FROM 
    GASTOS;
                                `, (error, gastosMensuales) => {
                                if (error) {
                                    throw error;
                                } else {
                                    res.render('layout', {
                                        title: 'Reportes',
                                        body: 'REPORTES/reportes',
                                        login: true,
                                        name: req.session.name,
                                        userId: req.session.userId,
                                        message: req.session.message,
                                        controlCaja: req.session.controlCaja,
                                        postresVendidos: postresVendidos,
                                        bebidasVendidas: bebidasVendidas,
                                        ventasMensuales: ventasMensuales,
                                        gastosMensuales: gastosMensuales
                                    });
                                }
                            });
                        }
                    });
                }
            });
        }
    });
});
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
app.get('/logout', (req, res) => {
    req.session.destroy(() => {
        res.redirect('/login');
    });
});

app.listen(3000, (req, res) => {
    console.log('Server is running in http://localhost:3000');
});
