-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 19, 2024 at 06:35 PM
-- Server version: 8.0.36
-- PHP Version: 8.1.6

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `aforos_malva`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `ConsultarCotizacionesAforos` ()   BEGIN
    SELECT
        ca.IDCOTIZACIONAFORO,
        ca.GASTO_DIESEL,
        ca.PROFUNDIDAD_POZO,
        ca.CANTIDAD_AGUA,
        CONCAT(ca.PRECIO_FINAL_TOTAL, ' MXN') AS PRECIO_FINAL_TOTAL,
        ca.STATUS AS STATUS_COTIZACION,
        CONCAT(p.NOMBRE, ' ', p.APELLIDO_PATERNO, ' ', p.APELLIDO_MATERNO) AS NOMBRE_CLIENTE,
        CONCAT(u.DETALLES_EXTRAS, ' - Distancia: ', u.DISTANCIA, ' KM') AS DETALLES_UBICACION,
        GROUP_CONCAT(DISTINCT CONCAT(pr.NOMBRE, ' (Cantidad: ', mc.CANTIDAD, ', Total: ', pr.PRECIO * mc.CANTIDAD, ' MXN)')) AS PRODUCTOS,
        GROUP_CONCAT(DISTINCT pv.NOMBRE_EMPRESA) AS PROVEEDORES,
        c.QUE_NECESITA,
        c.IDCLIENTE
    FROM
        COTIZACION_AFORO ca
    LEFT JOIN
        CLIENTE c ON ca.IDCLIENTE = c.IDCLIENTE
    LEFT JOIN
        UBICACION u ON c.IDUBICACION = u.IDUBICACION
    LEFT JOIN
        MUCHOSCOTIAFORO_PRODUCTO mc ON ca.IDCOTIZACIONAFORO = mc.IDCOTIZACIONAFORO
    LEFT JOIN
        PRODUCTO pr ON mc.IDPRODUCTO = pr.IDPRODUCTO
    LEFT JOIN
        PROVEEDOR pv ON pr.IDPROVEEDOR = pv.IDPROVEEDOR
    LEFT JOIN
        PERSONA p ON c.IDPERSONA = p.IDPERSONA
    WHERE
        ca.STATUS = 1
    GROUP BY
        ca.IDCOTIZACIONAFORO;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `obtener_clientes` ()   BEGIN
    SELECT c.IDCLIENTE,
           CONCAT(p.NOMBRE, ' ', p.APELLIDO_PATERNO, ' ', p.APELLIDO_MATERNO) AS NOMBRE_COMPLETO,
           u.DETALLES_EXTRAS AS UBICACION_DETALLES_EXTRAS,
           p.IDPERSONA,
           u.IDUBICACION,
           c.STATUS,
           c.QUE_NECESITA
    FROM CLIENTE c
    JOIN PERSONA p ON c.IDPERSONA = p.IDPERSONA
    JOIN UBICACION u ON c.IDUBICACION = u.IDUBICACION
    WHERE c.STATUS = 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `obtener_cotizaciones_equipamiento` ()   BEGIN

 SELECT
        ce.IDCOTIZACIONEQUIPAMIENTO,
        ce.MANO_OBRA,
        ce.ANTICIPO,
        CONCAT(ce.PRECIO_FINAL_TOTAL, ' MXN') AS PRECIO_FINAL_TOTAL,
        ce.STATUS AS STATUS_COTIZACION,
        CONCAT(p.NOMBRE, ' ', p.APELLIDO_PATERNO, ' ', p.APELLIDO_MATERNO) AS NOMBRE_CLIENTE,
        u.DETALLES_EXTRAS AS DETALLES_UBICACION,
        GROUP_CONCAT(DISTINCT CONCAT(pr.NOMBRE, ' (Cantidad: ', mep.CANTIDAD, ', Total: ', pr.PRECIO * mep.CANTIDAD, ' MXN)')) AS PRODUCTOS,
        GROUP_CONCAT(DISTINCT pv.NOMBRE_EMPRESA) AS PROVEEDORES,
        c.QUE_NECESITA
    FROM
        cotizacion_equipamiento ce
    LEFT JOIN
        cliente c ON ce.IDCLIENTE = c.IDCLIENTE
    LEFT JOIN
        persona p ON c.IDPERSONA = p.IDPERSONA
    LEFT JOIN
        ubicacion u ON c.IDUBICACION = u.IDUBICACION
    LEFT JOIN
        muchoscotiequipo_producto mep ON ce.IDCOTIZACIONEQUIPAMIENTO = mep.IDCOTIZACIONEQUIPAMIENTO
    LEFT JOIN
        producto pr ON mep.IDPRODUCTO = pr.IDPRODUCTO
    LEFT JOIN
        proveedor pv ON pr.IDPROVEEDOR = pv.IDPROVEEDOR
    WHERE
        ce.STATUS = 1
    GROUP BY
        ce.IDCOTIZACIONEQUIPAMIENTO;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `obtener_ticket_venta_aforo` (IN `_IDCOTIZACIONAFORO` INT)   BEGIN
    SELECT 
        IDVENTAAFORO, 
        IDCOTIZACIONAFORO, 
        FECHA, 
        CANTIDAD_VENTA, 
        DETALLES_EXTRAS, 
        STATUS
    FROM 
        VENTA_AFORO
    WHERE 
        IDCOTIZACIONAFORO = _IDCOTIZACIONAFORO;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `obtener_ubicaciones` ()   BEGIN
    SELECT * FROM UBICACION WHERE UBICACION.STATUS = 1;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `cliente`
--

CREATE TABLE `cliente` (
  `IDCLIENTE` int NOT NULL,
  `IDPERSONA` int DEFAULT NULL,
  `IDUBICACION` int DEFAULT NULL,
  `STATUS` int DEFAULT NULL,
  `QUE_NECESITA` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_spanish2_ci;

--
-- Dumping data for table `cliente`
--

INSERT INTO `cliente` (`IDCLIENTE`, `IDPERSONA`, `IDUBICACION`, `STATUS`, `QUE_NECESITA`) VALUES
(1, 7, 3, 2, 'CFE'),
(2, 8, 1, 0, 'SOLAR'),
(3, 12, 3, 0, 'SOLAR'),
(4, 13, 1, 0, 'SOLAR'),
(5, 14, 3, 2, 'SOLAR'),
(6, 15, 1, 2, 'EQUIPO'),
(7, 16, 3, 2, 'SOLAR'),
(8, 17, 3, 2, 'SOLAR'),
(9, 18, 1, 2, 'SOLAR'),
(10, 19, 1, 0, 'SOLAR'),
(11, 20, 3, 0, ''),
(12, 21, 3, 2, 'CFE'),
(13, 22, 1, 2, 'SOLAR'),
(14, 24, 3, 2, 'EQUIPO'),
(15, 26, 5, 2, 'EQUIPO'),
(16, 27, 5, 2, 'CFE'),
(17, 28, 3, 2, 'EQUIPO'),
(18, 29, 3, 2, 'AFORO'),
(19, 30, 5, 2, 'SOLAR'),
(20, 32, 1, 2, 'AFORO'),
(21, 33, 3, 2, 'SOLAR'),
(22, 34, 5, 1, 'AFORO'),
(23, 35, 1, 2, 'SOLAR'),
(24, 36, 3, 1, 'SOLAR'),
(25, 37, 6, 2, 'CFE');

--
-- Triggers `cliente`
--
DELIMITER $$
CREATE TRIGGER `actualizar_estado_persona` AFTER UPDATE ON `cliente` FOR EACH ROW BEGIN
    IF NEW.STATUS = 2 THEN
        UPDATE PERSONA
        SET STATUS = 2
        WHERE IDPERSONA = NEW.IDPERSONA;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `cliente_status_trigger` AFTER UPDATE ON `cliente` FOR EACH ROW BEGIN
    IF NEW.STATUS = 0 THEN
        UPDATE COTIZACION_AFORO
        SET STATUS = 0
        WHERE IDCLIENTE = NEW.IDCLIENTE;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `cotizacion_equipo_status_trigger` AFTER UPDATE ON `cliente` FOR EACH ROW BEGIN
    IF NEW.STATUS = 0 THEN
        UPDATE cotizacion_equipamiento
        SET STATUS = 0
        WHERE IDCLIENTE = NEW.IDCLIENTE;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_persona_status_cliente` AFTER UPDATE ON `cliente` FOR EACH ROW BEGIN
    IF NEW.STATUS = 0 THEN
        UPDATE persona SET STATUS = 0 WHERE IDPERSONA = NEW.IDPERSONA;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `cotizacion_aforo`
--

CREATE TABLE `cotizacion_aforo` (
  `IDCOTIZACIONAFORO` int NOT NULL,
  `GASTO_DIESEL` float DEFAULT NULL,
  `PROFUNDIDAD_POZO` float DEFAULT NULL,
  `CANTIDAD_AGUA` float DEFAULT NULL,
  `PRECIO_FINAL_TOTAL` float DEFAULT NULL,
  `IDCLIENTE` int DEFAULT NULL,
  `STATUS` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_spanish2_ci;

--
-- Dumping data for table `cotizacion_aforo`
--

INSERT INTO `cotizacion_aforo` (`IDCOTIZACIONAFORO`, `GASTO_DIESEL`, `PROFUNDIDAD_POZO`, `CANTIDAD_AGUA`, `PRECIO_FINAL_TOTAL`, `IDCLIENTE`, `STATUS`) VALUES
(1, 500, 25.55, 1200, 11000, 1, 2),
(3, 102.5, 200, 2, 25000, 4, 0),
(4, 15000, 12500, 2, 35000, 5, 2),
(5, 121, 1212, 1212, 121211, 6, 2),
(6, 1002, 505, 12, 102, 7, 2),
(7, 2112, 1, 21, 1, 8, 2),
(8, 445, 55, 55, 4444, 11, 0),
(9, 22, 22, 22, 11, 10, 0),
(10, 121, 1221, 1211, 1221, 9, 2),
(11, 324, 2342, 2323, 232323, 13, 2),
(12, 3123, 1312, 1231, 121, 14, 2),
(13, 12121, 1121, 121, 10002, 15, 2),
(14, 9890, 90890, 9890, 90890, 16, 2),
(15, 1221, 1212, 121, 112, 18, 2),
(16, 132, 2323, 2323, 23232, 20, 2),
(17, 21, 121, 121, 121, 22, 1),
(18, 1231, 12321, 123, 12312, 20, 1);

--
-- Triggers `cotizacion_aforo`
--
DELIMITER $$
CREATE TRIGGER `actualizar_estado_cliente` AFTER UPDATE ON `cotizacion_aforo` FOR EACH ROW BEGIN
    IF NEW.STATUS = 2 THEN
        UPDATE CLIENTE
        SET STATUS = 2
        WHERE IDCLIENTE = NEW.IDCLIENTE;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `agregar_venta_aforo` AFTER UPDATE ON `cotizacion_aforo` FOR EACH ROW BEGIN
    IF NEW.STATUS = 2 THEN
        INSERT INTO `VENTA_AFORO`
            (
                `IDCOTIZACIONAFORO`,
                `FECHA`,
                `CANTIDAD_VENTA`,
                `STATUS`,
                `DETALLES_EXTRAS`
            )
        VALUES
            (
                NEW.IDCOTIZACIONAFORO,
                CURDATE(),
                NEW.PRECIO_FINAL_TOTAL,
                1,
                CONCAT(
                    'FECHA: ', CURDATE(),
                    ', Gasto diesel: ', NEW.GASTO_DIESEL,
                    ', Profundidad del pozo: ', NEW.PROFUNDIDAD_POZO,
                    ', Cantidad de agua: ', NEW.CANTIDAD_AGUA,
                    ', Cliente: ',
                    (
                        SELECT CONCAT(NOMBRE, ' ', APELLIDO_PATERNO, ' ', APELLIDO_MATERNO)
                        FROM `PERSONA`
                        INNER JOIN `CLIENTE` ON `CLIENTE`.`IDPERSONA` = `PERSONA`.`IDPERSONA`
                        WHERE `CLIENTE`.`IDCLIENTE` = NEW.IDCLIENTE
                    ),
                    ', Ubicación: ',
                    (
                        SELECT CONCAT(DETALLES_EXTRAS, ' + ', DISTANCIA, ' KM')
                        FROM `UBICACION`
                        WHERE `UBICACION`.`IDUBICACION` = (
                            SELECT `IDUBICACION`
                            FROM `CLIENTE`
                            WHERE `CLIENTE`.`IDCLIENTE` = NEW.IDCLIENTE
                        )
                    ),
                    ', Productos: ',
                    (
                        SELECT GROUP_CONCAT(CONCAT(P.NOMBRE, ' (Cantidad: ', CP.CANTIDAD, ', Precio: $', P.PRECIO, ' MXN)') SEPARATOR ', ')
                        FROM muchoscotiaforo_producto CP
                        INNER JOIN PRODUCTO P ON CP.IDPRODUCTO = P.IDPRODUCTO
                        WHERE CP.IDCOTIZACIONAFORO = NEW.IDCOTIZACIONAFORO
                    ),
                    ', PRECIO DE VENTA: ', NEW.PRECIO_FINAL_TOTAL
                )
            );
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `cotizacion_equipamiento`
--

CREATE TABLE `cotizacion_equipamiento` (
  `IDCOTIZACIONEQUIPAMIENTO` int NOT NULL,
  `MANO_OBRA` float DEFAULT NULL,
  `ANTICIPO` float DEFAULT NULL,
  `PRECIO_FINAL_TOTAL` float DEFAULT NULL,
  `IDCLIENTE` int DEFAULT NULL,
  `STATUS` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_spanish2_ci;

--
-- Dumping data for table `cotizacion_equipamiento`
--

INSERT INTO `cotizacion_equipamiento` (`IDCOTIZACIONEQUIPAMIENTO`, `MANO_OBRA`, `ANTICIPO`, `PRECIO_FINAL_TOTAL`, `IDCLIENTE`, `STATUS`) VALUES
(1, 1500, 50, 1500, 9, 0),
(2, 1092, 1500, 1500, 10, 0),
(3, 12223, 23, 2300, 9, 2),
(4, 32, 232, 2323, 12, 2),
(5, 1212, 1212, 1212, 13, 2),
(6, 3212, 12312, 12312, 14, 2),
(7, 4234, 23423, 23423, 17, 2),
(8, 112, 12122, 21212100, 19, 2),
(9, 1121, 1212, 12212, 21, 2),
(10, 445, 4545, 4545, 23, 2),
(11, 31, 1312310, 12312, 24, 1),
(12, 12312, 31312, 12312, 25, 2);

--
-- Triggers `cotizacion_equipamiento`
--
DELIMITER $$
CREATE TRIGGER `agregar_venta_equipamiento` AFTER UPDATE ON `cotizacion_equipamiento` FOR EACH ROW BEGIN
    IF NEW.STATUS = 2 THEN
        INSERT INTO `VENTA_EQUIPAMIENTO`
        (
            `IDCOTIZACIONEQUIPAMIENTO`,
            `FECHA`,
            `CANTIDAD_VENTA`,
            `DETALLES_EXTRAS`,
            `STATUS`
        )
        VALUES
        (
            NEW.IDCOTIZACIONEQUIPAMIENTO,
            CURDATE(),
            NEW.PRECIO_FINAL_TOTAL,
            CONCAT(
                'FECHA: ', CURDATE(),
                ', Mano de obra: ', NEW.MANO_OBRA,
                ', Anticipo: ', NEW.ANTICIPO,
                ', Cliente: ',
                (
                    SELECT CONCAT(NOMBRE, ' ', APELLIDO_PATERNO, ' ', APELLIDO_MATERNO)
                    FROM `PERSONA`
                    INNER JOIN `CLIENTE` ON `CLIENTE`.`IDPERSONA` = `PERSONA`.`IDPERSONA`
                    WHERE `CLIENTE`.`IDCLIENTE` = NEW.IDCLIENTE
                ),
                ', Ubicación: ',
                (
                    SELECT CONCAT(DETALLES_EXTRAS, ' + ', DISTANCIA, ' KM')
                    FROM `UBICACION`
                    WHERE `UBICACION`.`IDUBICACION` = (
                        SELECT `IDUBICACION`
                        FROM `CLIENTE`
                        WHERE `CLIENTE`.`IDCLIENTE` = NEW.IDCLIENTE
                    )
                ),
                ', Productos: ',
                (
                    SELECT GROUP_CONCAT(CONCAT(P.NOMBRE, ' (Cantidad: ', CP.CANTIDAD, ', Precio: $', P.PRECIO, ' MXN)') SEPARATOR ', ')
                    FROM muchoscotiequipo_producto CP
                    INNER JOIN PRODUCTO P ON CP.IDPRODUCTO = P.IDPRODUCTO
                    WHERE CP.IDCOTIZACIONEQUIPAMIENTO = NEW.IDCOTIZACIONEQUIPAMIENTO
                ),
                ', PRECIO DE VENTA: ', NEW.PRECIO_FINAL_TOTAL
            ),
            1
        );
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `cotizacion_equipamiento_status_trigger` AFTER UPDATE ON `cotizacion_equipamiento` FOR EACH ROW BEGIN
    IF NEW.STATUS = 2 THEN
        UPDATE CLIENTE
        SET STATUS = 2
        WHERE IDCLIENTE = NEW.IDCLIENTE;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `muchoscotiaforo_producto`
--

CREATE TABLE `muchoscotiaforo_producto` (
  `IDCOTIZACIONAFORO` int NOT NULL,
  `IDPRODUCTO` int NOT NULL,
  `CANTIDAD` int NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_spanish2_ci;

--
-- Dumping data for table `muchoscotiaforo_producto`
--

INSERT INTO `muchoscotiaforo_producto` (`IDCOTIZACIONAFORO`, `IDPRODUCTO`, `CANTIDAD`) VALUES
(1, 1, 0),
(1, 3, 0),
(3, 1, 0),
(3, 3, 0),
(4, 3, 0),
(4, 4, 0),
(6, 3, 0),
(7, 3, 0),
(7, 4, 0),
(8, 4, 0),
(10, 1, 0),
(11, 1, 0),
(12, 3, 0),
(13, 1, 0),
(13, 3, 0),
(14, 1, 0),
(14, 3, 0),
(14, 4, 0),
(15, 1, 3),
(16, 3, 4),
(16, 4, 1);

-- --------------------------------------------------------

--
-- Table structure for table `muchoscotiequipo_producto`
--

CREATE TABLE `muchoscotiequipo_producto` (
  `IDCOTIZACIONEQUIPAMIENTO` int NOT NULL,
  `IDPRODUCTO` int NOT NULL,
  `CANTIDAD` int NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_spanish2_ci;

--
-- Dumping data for table `muchoscotiequipo_producto`
--

INSERT INTO `muchoscotiequipo_producto` (`IDCOTIZACIONEQUIPAMIENTO`, `IDPRODUCTO`, `CANTIDAD`) VALUES
(1, 1, 0),
(2, 3, 0),
(3, 3, 0),
(4, 1, 0),
(5, 4, 0),
(6, 1, 0),
(7, 3, 2),
(8, 4, 3),
(9, 4, 2),
(10, 4, 3),
(12, 4, 2);

-- --------------------------------------------------------

--
-- Table structure for table `persona`
--

CREATE TABLE `persona` (
  `IDPERSONA` int NOT NULL,
  `NOMBRE` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `APELLIDO_PATERNO` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `APELLIDO_MATERNO` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `STATUS` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_spanish2_ci;

--
-- Dumping data for table `persona`
--

INSERT INTO `persona` (`IDPERSONA`, `NOMBRE`, `APELLIDO_PATERNO`, `APELLIDO_MATERNO`, `STATUS`) VALUES
(1, 'Christian Emmanuel', 'Vital', 'Torres', 0),
(2, 'Christian Emmanuel', 'Vital', 'Torres', 1),
(3, 'aa', 'a', 'a', 0),
(4, 'Test2', 'Test', 'Test', 0),
(5, 'TEST', 'TEST', 'TEST', 0),
(6, 'test', 'test', 'test', 0),
(7, 'Juana', 'Patricio', 'García', 2),
(8, 'TEST', 'TEST', 'TEST', 0),
(9, 'Jonathan', 'Tavares', 'Ascencio', 0),
(10, 'Melissa', 'Maldonado', 'Vallecillo', 0),
(11, 'TEST NUEVO USUARIO EDITT', 'TEST2', 'TEST2', 0),
(12, 'TEST EDIT', 'TESTEEE', 'TESTEEE', 0),
(13, 'Pedrito', 'Pascal', 'Ramirez', 0),
(14, 'TEST', 'TEST', 'TEST', 2),
(15, 'TTT', 'TTT', 'TTT', 2),
(16, 'AAA', 'AAA', 'AAA', 2),
(17, 'Ger', 'sasa', 'asa', 2),
(18, 'nuevo', 'nuevo', 'nuevoAA', 2),
(19, 'DDD', 'DDD', 'DDD', 0),
(20, 'KLMLM', 'KLML', 'KLML', 0),
(21, 'test', 'test', 'test', 2),
(22, 'TEST', 'TEST', 'TEST', 2),
(23, 'test empleado', 'test', 'test', 1),
(24, 'dffds', 'dfsdfds', 'dsfdsf', 2),
(25, 'TEST`', 'TEST', 'TEST', 0),
(26, 'TEST', 'TWST', 'TEST', 2),
(27, 'gfygyj', 'ghvghv', 'gvghv', 2),
(28, 'a', 'a', 'a', 2),
(29, 'sdsf', 'sfdsfds', 'dsfsd', 2),
(30, 'Lolo', 'Lolo', 'Loloaa', 2),
(31, 'Melissa', 'Maldonado', 'Vallecillo', 1),
(32, 'Jonathan', 'Tavares', 'Ascensio', 2),
(33, 'Brian Oracio', 'Garcia ', 'Garcia', 2),
(34, 'TTEST', 'TEST', 'TEST', 1),
(35, 'EQUICLIENT', 'TESTQWQ', 'TESTQWQ', 2),
(36, 'dadasd', 'asdas', 'dasdas', 1),
(37, 'Mario', 'Rizo', 'Rizo', 2);

-- --------------------------------------------------------

--
-- Table structure for table `producto`
--

CREATE TABLE `producto` (
  `IDPRODUCTO` int NOT NULL,
  `NOMBRE` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `PRECIO` float DEFAULT NULL,
  `DETALLES_EXTRAS` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `STATUS` int DEFAULT NULL,
  `IDPROVEEDOR` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_spanish2_ci;

--
-- Dumping data for table `producto`
--

INSERT INTO `producto` (`IDPRODUCTO`, `NOMBRE`, `PRECIO`, `DETALLES_EXTRAS`, `STATUS`, `IDPROVEEDOR`) VALUES
(1, 'Producto Ejemplo', 10, 'Detalles adicionales del producto', 0, 3),
(2, 'TEST2', 12.23, 'TEST2', 0, 3),
(3, 'MOTOR 5 CABALLOS', 15000, 'Motor de 5 HP para aforo', 1, 1),
(4, 'TEST NUEVO', 16446, 'DETALLE', 0, 3),
(5, 'Tuberia', 1212, 'Metros', 0, 1),
(6, 'Motor', 1400, 'motor de 5 hp', 0, 3);

-- --------------------------------------------------------

--
-- Table structure for table `proveedor`
--

CREATE TABLE `proveedor` (
  `IDPROVEEDOR` int NOT NULL,
  `NOMBRE_EMPRESA` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `STATUS` int DEFAULT NULL,
  `TELEFONO` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `EMAIL` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_spanish2_ci;

--
-- Dumping data for table `proveedor`
--

INSERT INTO `proveedor` (`IDPROVEEDOR`, `NOMBRE_EMPRESA`, `STATUS`, `TELEFONO`, `EMAIL`) VALUES
(1, 'VILLAREAL', 1, '3471087655', 'nklasndlas@gmail.com'),
(2, 'TEST', 0, NULL, NULL),
(3, 'Ejemplo Inc', 0, '3456665432', 'ejemplo@gmail.com'),
(4, 'test nueva', 0, '23232323', 'test@gmail.com'),
(5, 'XASC', 0, '1223112', 'DSFVDS@GMAIL.COM');

--
-- Triggers `proveedor`
--
DELIMITER $$
CREATE TRIGGER `after_update_proveedor_status` AFTER UPDATE ON `proveedor` FOR EACH ROW BEGIN
    IF NEW.STATUS = 0 THEN
        UPDATE PRODUCTO SET STATUS = 0 WHERE IDPROVEEDOR = NEW.IDPROVEEDOR;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `reporte_aforo`
--

CREATE TABLE `reporte_aforo` (
  `IDREPORTEAFORO` int NOT NULL,
  `IDCOTIZACIONAFORO` int DEFAULT NULL,
  `RUTA_REPORTE` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `STATUS` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_spanish2_ci;

--
-- Dumping data for table `reporte_aforo`
--

INSERT INTO `reporte_aforo` (`IDREPORTEAFORO`, `IDCOTIZACIONAFORO`, `RUTA_REPORTE`, `STATUS`) VALUES
(1, 1, 'REPORTE TEST ID 4.pdf', 1),
(2, 4, '2.pdf', 1),
(3, 5, '2-1711826161620.pdf', 1),
(4, 6, 'PRIMER CRUD Y LOGIN.pdf', 1),
(5, 7, 'AnÃ¡lisis y tipos de Riesgos - GEST PROY SOFTW - CEVT.pdf', 1),
(6, 10, '5.1.9-packet-tracer - -configure-named-standard-ipv4-acls_es-XL (2).pdf', 1),
(7, 11, 'PRIMER CRUD Y LOGIN-1713280781684.pdf', 1),
(8, 12, '1.docx', 1),
(9, 13, 'PRIMER CRUD Y LOGIN-1713368247342.pdf', 1),
(10, 14, '7.6.1-packet-tracer---wan-concepts_es-XL.pdf', 1),
(11, 15, '7.6.1-packet-tracer---wan-concepts_es-XL-1713553258583.pdf', 1),
(12, 16, 'diagramasBIEN.pdf', 1);

-- --------------------------------------------------------

--
-- Table structure for table `ubicacion`
--

CREATE TABLE `ubicacion` (
  `IDUBICACION` int NOT NULL,
  `DISTANCIA` float DEFAULT NULL,
  `DETALLES_EXTRAS` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `STATUS` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_spanish2_ci;

--
-- Dumping data for table `ubicacion`
--

INSERT INTO `ubicacion` (`IDUBICACION`, `DISTANCIA`, `DETALLES_EXTRAS`, `STATUS`) VALUES
(1, 70.5, 'SAN JULIAN - ARANDAS', 1),
(2, 14, 'test', 0),
(3, 157.4, 'SAN JULIAN - GUADALAJARA ', 1),
(4, 60, 'SAN JULIAN - UNION DE SAN ANTONIO', 0),
(5, 123, 'SAN JULIAN - ACAPULCO', 1),
(6, 28, 'SAN JULIAN - SAN MIGUEL', 1);

-- --------------------------------------------------------

--
-- Table structure for table `usuarios`
--

CREATE TABLE `usuarios` (
  `IDUSUARIOS` int NOT NULL,
  `NOMBRE_USUARIO` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `PASSWORD` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `IDPERSONA` int DEFAULT NULL,
  `TIPO_USUARIO` int DEFAULT NULL,
  `STATUS` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_spanish2_ci;

--
-- Dumping data for table `usuarios`
--

INSERT INTO `usuarios` (`IDUSUARIOS`, `NOMBRE_USUARIO`, `PASSWORD`, `IDPERSONA`, `TIPO_USUARIO`, `STATUS`) VALUES
(1, 'CHRIS', '12345', 1, 1, 0),
(2, 'chris', '12345', 2, 1, 1),
(3, 'aa', '123', 3, 1, 0),
(4, 'Test', '12345', 4, 2, 0),
(5, 'test', '12345', 5, 2, 0),
(6, 'test', '12345', 6, 1, 0),
(7, 'Jony', '1234', 9, 1, 0),
(8, 'meli', '12345', 10, 1, 0),
(9, 'TEST2', '12345', 11, 1, 0),
(10, 'test', '12345', 23, 2, 1),
(11, 'test222', '12345', 25, 1, 0),
(12, 'meli', '12345', 31, 1, 1);

--
-- Triggers `usuarios`
--
DELIMITER $$
CREATE TRIGGER `update_persona_status` AFTER UPDATE ON `usuarios` FOR EACH ROW BEGIN
    IF NEW.STATUS = 0 THEN
        UPDATE PERSONA SET STATUS = 0 WHERE IDPERSONA = NEW.IDPERSONA;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `venta_aforo`
--

CREATE TABLE `venta_aforo` (
  `IDVENTAAFORO` int NOT NULL,
  `IDCOTIZACIONAFORO` int DEFAULT NULL,
  `FECHA` date DEFAULT NULL,
  `CANTIDAD_VENTA` float DEFAULT NULL,
  `DETALLES_EXTRAS` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `STATUS` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_spanish2_ci;

--
-- Dumping data for table `venta_aforo`
--

INSERT INTO `venta_aforo` (`IDVENTAAFORO`, `IDCOTIZACIONAFORO`, `FECHA`, `CANTIDAD_VENTA`, `DETALLES_EXTRAS`, `STATUS`) VALUES
(1, 1, '2024-03-29', 11000, 'FECHA: 2024-03-29, Gasto diesel: 500, Profundidad del pozo: 25.55, Cantidad de agua: 1200, Cliente: Juana Patricio García, Ubicación: SAN JULIAN - GUADALAJARA  + 157.4 KM, Productos: Producto Ejemplo, MOTOR 5 CABALLOS, PRECIO DE VENTA: 11000', 1),
(2, 4, '2024-03-29', 35000, 'FECHA: 2024-03-29, Gasto diesel: 15000, Profundidad del pozo: 12500, Cantidad de agua: 2, Cliente: TEST TEST TEST, Ubicación: SAN JULIAN - GUADALAJARA  + 157.4 KM, Productos: MOTOR 5 CABALLOS (PRECIO: $15000 MXN), TEST NUEVO (PRECIO: $16446 MXN), PRECIO DE VENTA: 35000', 1),
(3, 5, '2024-03-30', 121211, NULL, 1),
(4, 6, '2024-03-30', 102, 'FECHA: 2024-03-30, Gasto diesel: 1002, Profundidad del pozo: 505, Cantidad de agua: 12, Cliente: AAA AAA AAA, Ubicación: SAN JULIAN - GUADALAJARA  + 157.4 KM, Productos: MOTOR 5 CABALLOS (PRECIO: $15000 MXN), PRECIO DE VENTA: 102', 1),
(5, 7, '2024-03-30', 1, 'FECHA: 2024-03-30, Gasto diesel: 2112, Profundidad del pozo: 1, Cantidad de agua: 21, Cliente: Ger sasa asa, Ubicación: SAN JULIAN - GUADALAJARA  + 157.4 KM, Productos: MOTOR 5 CABALLOS (PRECIO: $15000 MXN), TEST NUEVO (PRECIO: $16446 MXN), PRECIO DE VENTA: 1', 1),
(6, 10, '2024-04-15', 1221, 'FECHA: 2024-04-15, Gasto diesel: 121, Profundidad del pozo: 1221, Cantidad de agua: 1211, Cliente: nuevo nuevo nuevoAA, Ubicación: SAN JULIAN - ARANDAS + 70.5 KM, Productos: Producto Ejemplo (PRECIO: $10 MXN), PRECIO DE VENTA: 1221', 1),
(7, 11, '2024-04-16', 232323, 'FECHA: 2024-04-16, Gasto diesel: 324, Profundidad del pozo: 2342, Cantidad de agua: 2323, Cliente: TEST TEST TEST, Ubicación: SAN JULIAN - ARANDAS + 70.5 KM, Productos: Producto Ejemplo (PRECIO: $10 MXN), PRECIO DE VENTA: 232323', 1),
(8, 12, '2024-04-16', 121, 'FECHA: 2024-04-16, Gasto diesel: 3123, Profundidad del pozo: 1312, Cantidad de agua: 1231, Cliente: dffds dfsdfds dsfdsf, Ubicación: SAN JULIAN - GUADALAJARA  + 157.4 KM, Productos: MOTOR 5 CABALLOS (PRECIO: $15000 MXN), PRECIO DE VENTA: 121', 1),
(9, 13, '2024-04-17', 10002, 'FECHA: 2024-04-17, Gasto diesel: 12121, Profundidad del pozo: 1121, Cantidad de agua: 121, Cliente: TEST TWST TEST, Ubicación: SAN JULIAN - ACAPULCO + 123 KM, Productos: Producto Ejemplo (PRECIO: $10 MXN), MOTOR 5 CABALLOS (PRECIO: $15000 MXN), PRECIO DE VENTA: 10002', 1),
(10, 14, '2024-04-19', 90890, 'FECHA: 2024-04-19, Gasto diesel: 9890, Profundidad del pozo: 90890, Cantidad de agua: 9890, Cliente: gfygyj ghvghv gvghv, Ubicación: SAN JULIAN - ACAPULCO + 123 KM, Productos: Producto Ejemplo (PRECIO: $10 MXN), MOTOR 5 CABALLOS (PRECIO: $15000 MXN), TEST NUEVO (PRECIO: $16446 MXN), PRECIO DE VENTA: 90890', 1),
(11, 15, '2024-04-19', 112, 'FECHA: 2024-04-19, Gasto diesel: 1221, Profundidad del pozo: 1212, Cantidad de agua: 121, Cliente: sdsf sfdsfds dsfsd, Ubicación: SAN JULIAN - GUADALAJARA  + 157.4 KM, Productos: Producto Ejemplo (Cantidad: 3, Precio: $10 MXN), PRECIO DE VENTA: 112', 1),
(12, 16, '2024-05-08', 23232, 'FECHA: 2024-05-08, Gasto diesel: 132, Profundidad del pozo: 2323, Cantidad de agua: 2323, Cliente: Jonathan Tavares Ascensio, Ubicación: SAN JULIAN - ARANDAS + 70.5 KM, Productos: MOTOR 5 CABALLOS (Cantidad: 4, Precio: $15000 MXN), TEST NUEVO (Cantidad: 1, Precio: $16446 MXN), PRECIO DE VENTA: 23232', 1);

-- --------------------------------------------------------

--
-- Table structure for table `venta_equipamiento`
--

CREATE TABLE `venta_equipamiento` (
  `IDVENTAEQUIPAMIENTO` int NOT NULL,
  `IDCOTIZACIONEQUIPAMIENTO` int DEFAULT NULL,
  `FECHA` date DEFAULT NULL,
  `CANTIDAD_VENTA` float DEFAULT NULL,
  `DETALLES_EXTRAS` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `STATUS` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_spanish2_ci;

--
-- Dumping data for table `venta_equipamiento`
--

INSERT INTO `venta_equipamiento` (`IDVENTAEQUIPAMIENTO`, `IDCOTIZACIONEQUIPAMIENTO`, `FECHA`, `CANTIDAD_VENTA`, `DETALLES_EXTRAS`, `STATUS`) VALUES
(1, 3, '2024-04-09', 2300, 'FECHA: 2024-04-09, Mano de obra: 12223, Anticipo: 23, Cliente: nuevo nuevo nuevoAA, Ubicación: SAN JULIAN - ARANDAS + 70.5 KM, Productos: MOTOR 5 CABALLOS (PRECIO: $15000 MXN), PRECIO DE VENTA: 2300', 1),
(2, 4, '2024-04-15', 2323, 'FECHA: 2024-04-15, Mano de obra: 32, Anticipo: 232, Cliente: test test test, Ubicación: SAN JULIAN - GUADALAJARA  + 157.4 KM, Productos: Producto Ejemplo (PRECIO: $10 MXN), PRECIO DE VENTA: 2323', 1),
(3, 5, '2024-04-16', 1212, 'FECHA: 2024-04-16, Mano de obra: 1212, Anticipo: 1212, Cliente: TEST TEST TEST, Ubicación: SAN JULIAN - ARANDAS + 70.5 KM, Productos: TEST NUEVO (PRECIO: $16446 MXN), PRECIO DE VENTA: 1212', 1),
(4, 6, '2024-04-16', 12312, 'FECHA: 2024-04-16, Mano de obra: 3212, Anticipo: 12312, Cliente: dffds dfsdfds dsfdsf, Ubicación: SAN JULIAN - GUADALAJARA  + 157.4 KM, Productos: Producto Ejemplo (PRECIO: $10 MXN), PRECIO DE VENTA: 12312', 1),
(5, 7, '2024-04-19', 23423, 'FECHA: 2024-04-19, Mano de obra: 4234, Anticipo: 23423, Cliente: a a a, Ubicación: SAN JULIAN - GUADALAJARA  + 157.4 KM, Productos: MOTOR 5 CABALLOS (PRECIO: $15000 MXN), PRECIO DE VENTA: 23423', 1),
(6, 8, '2024-04-24', 21212100, 'FECHA: 2024-04-24, Mano de obra: 112, Anticipo: 12122, Cliente: Lolo Lolo Loloaa, Ubicación: SAN JULIAN - ACAPULCO + 123 KM, Productos: TEST NUEVO (Cantidad: 3, Precio: $16446 MXN), PRECIO DE VENTA: 21212100', 1),
(7, 9, '2024-04-30', 12212, 'FECHA: 2024-04-30, Mano de obra: 1121, Anticipo: 1212, Cliente: Brian Oracio Garcia  Garcia, Ubicación: SAN JULIAN - GUADALAJARA  + 157.4 KM, Productos: TEST NUEVO (Cantidad: 2, Precio: $16446 MXN), PRECIO DE VENTA: 12212', 1),
(8, 12, '2024-05-08', 12312, 'FECHA: 2024-05-08, Mano de obra: 12312, Anticipo: 31312, Cliente: Mario Rizo Rizo, Ubicación: SAN JULIAN - SAN MIGUEL + 28 KM, Productos: TEST NUEVO (Cantidad: 2, Precio: $16446 MXN), PRECIO DE VENTA: 12312', 1),
(9, 10, '2024-05-11', 4545, 'FECHA: 2024-05-11, Mano de obra: 445, Anticipo: 4545, Cliente: EQUICLIENT TESTQWQ TESTQWQ, Ubicación: SAN JULIAN - ARANDAS + 70.5 KM, Productos: TEST NUEVO (Cantidad: 3, Precio: $16446 MXN), PRECIO DE VENTA: 4545', 1);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vista_producto`
-- (See below for the actual view)
--
CREATE TABLE `vista_producto` (
`DETALLES_EXTRAS` varchar(150)
,`IDPRODUCTO` int
,`NOMBRE` varchar(50)
,`NOMBRE_EMPRESA` varchar(50)
,`PRECIO` float
,`STATUS` int
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vista_proveedor_extendida`
-- (See below for the actual view)
--
CREATE TABLE `vista_proveedor_extendida` (
`EMAIL` varchar(150)
,`IDPROVEEDOR` int
,`NOMBRE_EMPRESA` varchar(50)
,`STATUS` int
,`TELEFONO` varchar(20)
);

-- --------------------------------------------------------

--
-- Structure for view `vista_producto`
--
DROP TABLE IF EXISTS `vista_producto`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_producto`  AS SELECT `p`.`IDPRODUCTO` AS `IDPRODUCTO`, `p`.`NOMBRE` AS `NOMBRE`, `p`.`PRECIO` AS `PRECIO`, `p`.`DETALLES_EXTRAS` AS `DETALLES_EXTRAS`, `p`.`STATUS` AS `STATUS`, `pr`.`NOMBRE_EMPRESA` AS `NOMBRE_EMPRESA` FROM (`producto` `p` join `proveedor` `pr` on((`p`.`IDPROVEEDOR` = `pr`.`IDPROVEEDOR`))) WHERE (`p`.`STATUS` = 1)  ;

-- --------------------------------------------------------

--
-- Structure for view `vista_proveedor_extendida`
--
DROP TABLE IF EXISTS `vista_proveedor_extendida`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_proveedor_extendida`  AS SELECT `proveedor`.`IDPROVEEDOR` AS `IDPROVEEDOR`, `proveedor`.`NOMBRE_EMPRESA` AS `NOMBRE_EMPRESA`, `proveedor`.`STATUS` AS `STATUS`, `proveedor`.`TELEFONO` AS `TELEFONO`, `proveedor`.`EMAIL` AS `EMAIL` FROM `proveedor` WHERE (`proveedor`.`STATUS` = 1)  ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`IDCLIENTE`),
  ADD KEY `IDPERSONA` (`IDPERSONA`),
  ADD KEY `IDUBICACION` (`IDUBICACION`),
  ADD KEY `idx_NECESIDAD` (`QUE_NECESITA`),
  ADD KEY `idx_STATUS` (`STATUS`);

--
-- Indexes for table `cotizacion_aforo`
--
ALTER TABLE `cotizacion_aforo`
  ADD PRIMARY KEY (`IDCOTIZACIONAFORO`),
  ADD KEY `IDCLIENTE` (`IDCLIENTE`),
  ADD KEY `idx_status` (`STATUS`);

--
-- Indexes for table `cotizacion_equipamiento`
--
ALTER TABLE `cotizacion_equipamiento`
  ADD PRIMARY KEY (`IDCOTIZACIONEQUIPAMIENTO`),
  ADD KEY `IDCLIENTE` (`IDCLIENTE`),
  ADD KEY `idx_status` (`STATUS`);

--
-- Indexes for table `muchoscotiaforo_producto`
--
ALTER TABLE `muchoscotiaforo_producto`
  ADD PRIMARY KEY (`IDCOTIZACIONAFORO`,`IDPRODUCTO`),
  ADD KEY `IDPRODUCTO` (`IDPRODUCTO`);

--
-- Indexes for table `muchoscotiequipo_producto`
--
ALTER TABLE `muchoscotiequipo_producto`
  ADD PRIMARY KEY (`IDCOTIZACIONEQUIPAMIENTO`,`IDPRODUCTO`),
  ADD KEY `IDPRODUCTO` (`IDPRODUCTO`);

--
-- Indexes for table `persona`
--
ALTER TABLE `persona`
  ADD PRIMARY KEY (`IDPERSONA`),
  ADD KEY `idx_status` (`STATUS`);

--
-- Indexes for table `producto`
--
ALTER TABLE `producto`
  ADD PRIMARY KEY (`IDPRODUCTO`),
  ADD KEY `fk_proveedor` (`IDPROVEEDOR`),
  ADD KEY `idx_status` (`STATUS`),
  ADD KEY `idx_nombre_precio` (`NOMBRE`,`PRECIO`);

--
-- Indexes for table `proveedor`
--
ALTER TABLE `proveedor`
  ADD PRIMARY KEY (`IDPROVEEDOR`),
  ADD KEY `idx_status` (`STATUS`),
  ADD KEY `idx_nombre_empresa` (`NOMBRE_EMPRESA`);

--
-- Indexes for table `reporte_aforo`
--
ALTER TABLE `reporte_aforo`
  ADD PRIMARY KEY (`IDREPORTEAFORO`),
  ADD KEY `IDCOTIZACIONAFORO` (`IDCOTIZACIONAFORO`),
  ADD KEY `STATUS` (`STATUS`);

--
-- Indexes for table `ubicacion`
--
ALTER TABLE `ubicacion`
  ADD PRIMARY KEY (`IDUBICACION`),
  ADD KEY `STATUS` (`STATUS`);

--
-- Indexes for table `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`IDUSUARIOS`),
  ADD KEY `IDPERSONA` (`IDPERSONA`),
  ADD KEY `TIPO_USUARIO` (`TIPO_USUARIO`),
  ADD KEY `STATUS` (`STATUS`),
  ADD KEY `NOMBRE_USUARIO` (`NOMBRE_USUARIO`);

--
-- Indexes for table `venta_aforo`
--
ALTER TABLE `venta_aforo`
  ADD PRIMARY KEY (`IDVENTAAFORO`),
  ADD KEY `IDCOTIZACIONAFORO` (`IDCOTIZACIONAFORO`),
  ADD KEY `FECHA` (`FECHA`);

--
-- Indexes for table `venta_equipamiento`
--
ALTER TABLE `venta_equipamiento`
  ADD PRIMARY KEY (`IDVENTAEQUIPAMIENTO`),
  ADD KEY `IDCOTIZACIONEQUIPAMIENTO` (`IDCOTIZACIONEQUIPAMIENTO`),
  ADD KEY `FECHA` (`FECHA`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `cliente`
--
ALTER TABLE `cliente`
  MODIFY `IDCLIENTE` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `cotizacion_aforo`
--
ALTER TABLE `cotizacion_aforo`
  MODIFY `IDCOTIZACIONAFORO` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `cotizacion_equipamiento`
--
ALTER TABLE `cotizacion_equipamiento`
  MODIFY `IDCOTIZACIONEQUIPAMIENTO` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `persona`
--
ALTER TABLE `persona`
  MODIFY `IDPERSONA` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT for table `producto`
--
ALTER TABLE `producto`
  MODIFY `IDPRODUCTO` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `proveedor`
--
ALTER TABLE `proveedor`
  MODIFY `IDPROVEEDOR` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `reporte_aforo`
--
ALTER TABLE `reporte_aforo`
  MODIFY `IDREPORTEAFORO` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `ubicacion`
--
ALTER TABLE `ubicacion`
  MODIFY `IDUBICACION` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `IDUSUARIOS` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `venta_aforo`
--
ALTER TABLE `venta_aforo`
  MODIFY `IDVENTAAFORO` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `venta_equipamiento`
--
ALTER TABLE `venta_equipamiento`
  MODIFY `IDVENTAEQUIPAMIENTO` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `cliente`
--
ALTER TABLE `cliente`
  ADD CONSTRAINT `cliente_ibfk_1` FOREIGN KEY (`IDPERSONA`) REFERENCES `persona` (`IDPERSONA`),
  ADD CONSTRAINT `cliente_ibfk_2` FOREIGN KEY (`IDUBICACION`) REFERENCES `ubicacion` (`IDUBICACION`);

--
-- Constraints for table `cotizacion_aforo`
--
ALTER TABLE `cotizacion_aforo`
  ADD CONSTRAINT `cotizacion_aforo_ibfk_1` FOREIGN KEY (`IDCLIENTE`) REFERENCES `cliente` (`IDCLIENTE`);

--
-- Constraints for table `cotizacion_equipamiento`
--
ALTER TABLE `cotizacion_equipamiento`
  ADD CONSTRAINT `cotizacion_equipamiento_ibfk_1` FOREIGN KEY (`IDCLIENTE`) REFERENCES `cliente` (`IDCLIENTE`);

--
-- Constraints for table `muchoscotiaforo_producto`
--
ALTER TABLE `muchoscotiaforo_producto`
  ADD CONSTRAINT `muchoscotiaforo_producto_ibfk_1` FOREIGN KEY (`IDCOTIZACIONAFORO`) REFERENCES `cotizacion_aforo` (`IDCOTIZACIONAFORO`),
  ADD CONSTRAINT `muchoscotiaforo_producto_ibfk_2` FOREIGN KEY (`IDPRODUCTO`) REFERENCES `producto` (`IDPRODUCTO`);

--
-- Constraints for table `muchoscotiequipo_producto`
--
ALTER TABLE `muchoscotiequipo_producto`
  ADD CONSTRAINT `muchoscotiequipo_producto_ibfk_1` FOREIGN KEY (`IDCOTIZACIONEQUIPAMIENTO`) REFERENCES `cotizacion_equipamiento` (`IDCOTIZACIONEQUIPAMIENTO`),
  ADD CONSTRAINT `muchoscotiequipo_producto_ibfk_2` FOREIGN KEY (`IDPRODUCTO`) REFERENCES `producto` (`IDPRODUCTO`);

--
-- Constraints for table `producto`
--
ALTER TABLE `producto`
  ADD CONSTRAINT `fk_proveedor` FOREIGN KEY (`IDPROVEEDOR`) REFERENCES `proveedor` (`IDPROVEEDOR`);

--
-- Constraints for table `reporte_aforo`
--
ALTER TABLE `reporte_aforo`
  ADD CONSTRAINT `reporte_aforo_ibfk_1` FOREIGN KEY (`IDCOTIZACIONAFORO`) REFERENCES `cotizacion_aforo` (`IDCOTIZACIONAFORO`);

--
-- Constraints for table `usuarios`
--
ALTER TABLE `usuarios`
  ADD CONSTRAINT `usuarios_ibfk_1` FOREIGN KEY (`IDPERSONA`) REFERENCES `persona` (`IDPERSONA`);

--
-- Constraints for table `venta_aforo`
--
ALTER TABLE `venta_aforo`
  ADD CONSTRAINT `venta_aforo_ibfk_1` FOREIGN KEY (`IDCOTIZACIONAFORO`) REFERENCES `cotizacion_aforo` (`IDCOTIZACIONAFORO`);

--
-- Constraints for table `venta_equipamiento`
--
ALTER TABLE `venta_equipamiento`
  ADD CONSTRAINT `venta_equipamiento_ibfk_1` FOREIGN KEY (`IDCOTIZACIONEQUIPAMIENTO`) REFERENCES `cotizacion_equipamiento` (`IDCOTIZACIONEQUIPAMIENTO`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
