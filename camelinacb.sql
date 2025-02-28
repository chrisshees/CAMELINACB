
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

CREATE TABLE `areas` (
  `IDAREA` int NOT NULL,
  `NOMBRE_AREA` varchar(50) NOT NULL,
  `ESTADO` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `bebidas`
--

CREATE TABLE `bebidas` (
  `IDBEBIDAS` int NOT NULL,
  `NOMBRE` varchar(50) DEFAULT NULL,
  `PRECIO` decimal(10,2) DEFAULT NULL,
  `FOTO` varchar(255) DEFAULT NULL,
  `DESCRIPCION` text,
  `ESTADO` int DEFAULT NULL,
  `IDCATEGORIA` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


--
-- Table structure for table `categorias`
--

CREATE TABLE `categorias` (
  `IDCATEGORIA` int NOT NULL,
  `NOMBRE` varchar(255) DEFAULT NULL,
  `ESTADO` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-----------------------------

--
-- Table structure for table `controlcaja`
--

CREATE TABLE `controlcaja` (
  `IDCONTROLCAJA` int NOT NULL,
  `FECHA` date DEFAULT NULL,
  `INICIODIA` decimal(10,2) DEFAULT NULL,
  `FINDIA` decimal(10,2) DEFAULT NULL,
  `FALTASOBRA` decimal(10,2) DEFAULT NULL,
  `TOTALCAJA` decimal(10,2) DEFAULT NULL,
  `NOTAS` text,
  `IDUSUARIO` int DEFAULT NULL,
  `ESTADO` int DEFAULT NULL,
  `MONTOACTUAL` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Table structure for table `gastos`
--

CREATE TABLE `gastos` (
  `IDGASTOS` int NOT NULL,
  `FECHA` datetime DEFAULT NULL,
  `MONTO` decimal(10,2) DEFAULT NULL,
  `DESCRIPCION` text,
  `ESTADO` int DEFAULT NULL,
  `REALIZADO_POR` varchar(250) DEFAULT NULL,
  `ACCION` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


--
-- Table structure for table `historial_ventas`
--

CREATE TABLE `historial_ventas` (
  `IDHISTORIAL` int NOT NULL,
  `IDVENTA` int DEFAULT NULL,
  `TOTAL` decimal(10,2) DEFAULT NULL,
  `FECHA` datetime DEFAULT NULL,
  `LISTA_BEBIDAS_PRECIO` text,
  `LISTA_POSTRES_PRECIO` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Table structure for table `mesas`
--

CREATE TABLE `mesas` (
  `IDMESA` int NOT NULL,
  `NOMBRE` varchar(50) DEFAULT NULL,
  `DISPONIBLE` int DEFAULT NULL,
  `ESTADO` int DEFAULT NULL,
  `IDAREA` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `persona`
--

CREATE TABLE `persona` (
  `IDPERSONA` int NOT NULL,
  `NOMBRE` varchar(50) DEFAULT NULL,
  `APELLIDOPATERNO` varchar(50) DEFAULT NULL,
  `APELLIDOMATERNO` varchar(50) DEFAULT NULL,
  `ESTADO` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `postres`
--

CREATE TABLE `postres` (
  `IDPOSTRES` int NOT NULL,
  `NOMBRE` varchar(50) DEFAULT NULL,
  `PRECIO` decimal(10,2) DEFAULT NULL,
  `FOTO` varchar(255) DEFAULT NULL,
  `DESCRIPCION` text,
  `ESTADO` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Table structure for table `producto`
--

CREATE TABLE `producto` (
  `IDPRODUCTO` int NOT NULL,
  `NOMBRE` varchar(50) DEFAULT NULL,
  `PRECIO` decimal(10,2) DEFAULT NULL,
  `ESTADO` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `proveedor`
--

CREATE TABLE `proveedor` (
  `IDPROVEEDOR` int NOT NULL,
  `NOMBRE` varchar(50) DEFAULT NULL,
  `EMAIL` varchar(100) DEFAULT NULL,
  `TELEFONO` varchar(15) DEFAULT NULL,
  `ESTADO` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `proveedor_producto`
--

CREATE TABLE `proveedor_producto` (
  `IDPROVEEDOR` int NOT NULL,
  `IDPRODUCTO` int NOT NULL,
  `ESTADO` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `session_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `expires` int UNSIGNED NOT NULL,
  `data` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sugerencias`
--

CREATE TABLE `sugerencias` (
  `IDSUGERENCIAS` int NOT NULL,
  `IDUSUARIO` int DEFAULT NULL,
  `FECHA` date DEFAULT NULL,
  `COMENTARIO` text,
  `ESTADO` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `usuarios`
--

CREATE TABLE `usuarios` (
  `IDUSUARIO` int NOT NULL,
  `IDPERSONA` int DEFAULT NULL,
  `NOMBREDEUSUARIO` varchar(50) DEFAULT NULL,
  `PASSWORD` varchar(255) DEFAULT NULL,
  `TIPO` varchar(50) DEFAULT NULL,
  `ESTADO` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Triggers `usuarios`
--
DELIMITER $$
CREATE TRIGGER `after_update_usuario_estado` AFTER UPDATE ON `usuarios` FOR EACH ROW BEGIN
    IF NEW.ESTADO = 0 THEN
        UPDATE PERSONA
        SET ESTADO = 0
        WHERE IDPERSONA = NEW.IDPERSONA;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `venta`
--

CREATE TABLE `venta` (
  `IDVENTA` int NOT NULL,
  `IDMESA` int DEFAULT NULL,
  `TOTAL` float DEFAULT NULL,
  `ESTADO` int DEFAULT NULL,
  `IDUSUARIO` int DEFAULT NULL,
  `FECHA` datetime DEFAULT NULL,
  `TIPO` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Triggers `venta`
--
DELIMITER $$
CREATE TRIGGER `after_venta_update` AFTER UPDATE ON `venta` FOR EACH ROW BEGIN
    DECLARE bebidas_text TEXT;
    DECLARE postres_text TEXT;

    IF NEW.ESTADO = 2 THEN
        
        SELECT GROUP_CONCAT(CONCAT(B.NOMBRE, ' (', VB.CANTIDAD, ' x $', B.PRECIO, ')') SEPARATOR ', ')
        INTO bebidas_text
        FROM VENTA_BEBIDAS VB
        JOIN BEBIDAS B ON VB.IDBEBIDAS = B.IDBEBIDAS
        WHERE VB.IDVENTA = NEW.IDVENTA;

        
        SELECT GROUP_CONCAT(CONCAT(P.NOMBRE, ' (', VP.CANTIDAD, ' x $', P.PRECIO, ')') SEPARATOR ', ')
        INTO postres_text
        FROM VENTA_POSTRES VP
        JOIN POSTRES P ON VP.IDPOSTRES = P.IDPOSTRES
        WHERE VP.IDVENTA = NEW.IDVENTA;

        
        INSERT INTO HISTORIAL_VENTAS (IDVENTA, TOTAL, FECHA, LISTA_BEBIDAS_PRECIO, LISTA_POSTRES_PRECIO)
        VALUES (NEW.IDVENTA, NEW.TOTAL, NEW.FECHA, bebidas_text, postres_text);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_tipo_on_estado_change` BEFORE UPDATE ON `venta` FOR EACH ROW BEGIN
    SET NEW.TIPO = NEW.ESTADO;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `venta_bebidas`
--

CREATE TABLE `venta_bebidas` (
  `IDVENTA` int NOT NULL,
  `IDBEBIDAS` int NOT NULL,
  `CANTIDAD` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `venta_postres`
--

CREATE TABLE `venta_postres` (
  `IDVENTA` int NOT NULL,
  `IDPOSTRES` int NOT NULL,
  `CANTIDAD` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-----------------------

--
-- Stand-in structure for view `vistausuariosactivos`
-- (See below for the actual view)
--
CREATE TABLE `vistausuariosactivos` (
`IDUSUARIO` int
,`NombreCompleto` varchar(152)
,`NOMBREDEUSUARIO` varchar(50)
,`PASSWORD` varchar(255)
,`TIPO` varchar(50)
,`ESTADO` int
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vista_bebidas`
-- (See below for the actual view)
--
CREATE TABLE `vista_bebidas` (
`IDBEBIDAS` int
,`NOMBRE` varchar(50)
,`PRECIO` decimal(10,2)
,`FOTO` varchar(255)
,`DESCRIPCION` text
,`IDCATEGORIA` int
,`ESTADO` int
,`CATEGORIA_NOMBRE` varchar(255)
);

-- --------------------------------------------------------

--
-- Structure for view `vistausuariosactivos`
--
DROP TABLE IF EXISTS `vistausuariosactivos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vistausuariosactivos`  AS SELECT `u`.`IDUSUARIO` AS `IDUSUARIO`, concat(`p`.`NOMBRE`,' ',`p`.`APELLIDOPATERNO`,' ',`p`.`APELLIDOMATERNO`) AS `NombreCompleto`, `u`.`NOMBREDEUSUARIO` AS `NOMBREDEUSUARIO`, `u`.`PASSWORD` AS `PASSWORD`, `u`.`TIPO` AS `TIPO`, `u`.`ESTADO` AS `ESTADO` FROM (`usuarios` `u` join `persona` `p` on((`u`.`IDPERSONA` = `p`.`IDPERSONA`))) WHERE (`u`.`ESTADO` = 1)  ;

-- --------------------------------------------------------

--
-- Structure for view `vista_bebidas`
--
DROP TABLE IF EXISTS `vista_bebidas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_bebidas`  AS SELECT `bebidas`.`IDBEBIDAS` AS `IDBEBIDAS`, `bebidas`.`NOMBRE` AS `NOMBRE`, `bebidas`.`PRECIO` AS `PRECIO`, `bebidas`.`FOTO` AS `FOTO`, `bebidas`.`DESCRIPCION` AS `DESCRIPCION`, `bebidas`.`IDCATEGORIA` AS `IDCATEGORIA`, `bebidas`.`ESTADO` AS `ESTADO`, `categorias`.`NOMBRE` AS `CATEGORIA_NOMBRE` FROM (`bebidas` join `categorias` on((`bebidas`.`IDCATEGORIA` = `categorias`.`IDCATEGORIA`))) WHERE (`bebidas`.`ESTADO` = 1)  ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `areas`
--
ALTER TABLE `areas`
  ADD PRIMARY KEY (`IDAREA`);

--
-- Indexes for table `bebidas`
--
ALTER TABLE `bebidas`
  ADD PRIMARY KEY (`IDBEBIDAS`),
  ADD KEY `IDCATEGORIA` (`IDCATEGORIA`);

--
-- Indexes for table `categorias`
--
ALTER TABLE `categorias`
  ADD PRIMARY KEY (`IDCATEGORIA`);

--
-- Indexes for table `controlcaja`
--
ALTER TABLE `controlcaja`
  ADD PRIMARY KEY (`IDCONTROLCAJA`),
  ADD KEY `IDUsuario` (`IDUSUARIO`);

--
-- Indexes for table `gastos`
--
ALTER TABLE `gastos`
  ADD PRIMARY KEY (`IDGASTOS`);

--
-- Indexes for table `historial_ventas`
--
ALTER TABLE `historial_ventas`
  ADD PRIMARY KEY (`IDHISTORIAL`),
  ADD KEY `IDVENTA` (`IDVENTA`);

--
-- Indexes for table `mesas`
--
ALTER TABLE `mesas`
  ADD PRIMARY KEY (`IDMESA`),
  ADD KEY `FK_MESAS_AREAS` (`IDAREA`);

--
-- Indexes for table `persona`
--
ALTER TABLE `persona`
  ADD PRIMARY KEY (`IDPERSONA`);

--
-- Indexes for table `postres`
--
ALTER TABLE `postres`
  ADD PRIMARY KEY (`IDPOSTRES`);

--
-- Indexes for table `producto`
--
ALTER TABLE `producto`
  ADD PRIMARY KEY (`IDPRODUCTO`);

--
-- Indexes for table `proveedor`
--
ALTER TABLE `proveedor`
  ADD PRIMARY KEY (`IDPROVEEDOR`);

--
-- Indexes for table `proveedor_producto`
--
ALTER TABLE `proveedor_producto`
  ADD PRIMARY KEY (`IDPROVEEDOR`,`IDPRODUCTO`),
  ADD KEY `IDProducto` (`IDPRODUCTO`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`session_id`);

--
-- Indexes for table `sugerencias`
--
ALTER TABLE `sugerencias`
  ADD PRIMARY KEY (`IDSUGERENCIAS`),
  ADD KEY `IDUsuario` (`IDUSUARIO`);

--
-- Indexes for table `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`IDUSUARIO`),
  ADD UNIQUE KEY `NombreDeUsuario` (`NOMBREDEUSUARIO`),
  ADD KEY `Persona` (`IDPERSONA`);

--
-- Indexes for table `venta`
--
ALTER TABLE `venta`
  ADD PRIMARY KEY (`IDVENTA`),
  ADD KEY `fk_idmesa` (`IDMESA`),
  ADD KEY `fk_idusuario` (`IDUSUARIO`);

--
-- Indexes for table `venta_bebidas`
--
ALTER TABLE `venta_bebidas`
  ADD PRIMARY KEY (`IDVENTA`,`IDBEBIDAS`),
  ADD KEY `IDBEBIDA` (`IDBEBIDAS`);

--
-- Indexes for table `venta_postres`
--
ALTER TABLE `venta_postres`
  ADD PRIMARY KEY (`IDVENTA`,`IDPOSTRES`),
  ADD KEY `IDPOSTRES` (`IDPOSTRES`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `areas`
--
ALTER TABLE `areas`
  MODIFY `IDAREA` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `bebidas`
--
ALTER TABLE `bebidas`
  MODIFY `IDBEBIDAS` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `categorias`
--
ALTER TABLE `categorias`
  MODIFY `IDCATEGORIA` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `controlcaja`
--
ALTER TABLE `controlcaja`
  MODIFY `IDCONTROLCAJA` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `gastos`
--
ALTER TABLE `gastos`
  MODIFY `IDGASTOS` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `historial_ventas`
--
ALTER TABLE `historial_ventas`
  MODIFY `IDHISTORIAL` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `mesas`
--
ALTER TABLE `mesas`
  MODIFY `IDMESA` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `persona`
--
ALTER TABLE `persona`
  MODIFY `IDPERSONA` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `postres`
--
ALTER TABLE `postres`
  MODIFY `IDPOSTRES` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `producto`
--
ALTER TABLE `producto`
  MODIFY `IDPRODUCTO` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `proveedor`
--
ALTER TABLE `proveedor`
  MODIFY `IDPROVEEDOR` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `sugerencias`
--
ALTER TABLE `sugerencias`
  MODIFY `IDSUGERENCIAS` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `IDUSUARIO` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `venta`
--
ALTER TABLE `venta`
  MODIFY `IDVENTA` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bebidas`
--
ALTER TABLE `bebidas`
  ADD CONSTRAINT `bebidas_ibfk_1` FOREIGN KEY (`IDCATEGORIA`) REFERENCES `categorias` (`IDCATEGORIA`);

--
-- Constraints for table `controlcaja`
--
ALTER TABLE `controlcaja`
  ADD CONSTRAINT `controlcaja_ibfk_1` FOREIGN KEY (`IDUSUARIO`) REFERENCES `usuarios` (`IDUSUARIO`);

--
-- Constraints for table `historial_ventas`
--
ALTER TABLE `historial_ventas`
  ADD CONSTRAINT `historial_ventas_ibfk_1` FOREIGN KEY (`IDVENTA`) REFERENCES `venta` (`IDVENTA`);

--
-- Constraints for table `mesas`
--
ALTER TABLE `mesas`
  ADD CONSTRAINT `FK_MESAS_AREAS` FOREIGN KEY (`IDAREA`) REFERENCES `areas` (`IDAREA`);

--
-- Constraints for table `proveedor_producto`
--
ALTER TABLE `proveedor_producto`
  ADD CONSTRAINT `proveedor_producto_ibfk_1` FOREIGN KEY (`IDPROVEEDOR`) REFERENCES `proveedor` (`IDPROVEEDOR`),
  ADD CONSTRAINT `proveedor_producto_ibfk_2` FOREIGN KEY (`IDPRODUCTO`) REFERENCES `producto` (`IDPRODUCTO`);

--
-- Constraints for table `sugerencias`
--
ALTER TABLE `sugerencias`
  ADD CONSTRAINT `sugerencias_ibfk_1` FOREIGN KEY (`IDUSUARIO`) REFERENCES `usuarios` (`IDUSUARIO`);

--
-- Constraints for table `usuarios`
--
ALTER TABLE `usuarios`
  ADD CONSTRAINT `usuarios_ibfk_1` FOREIGN KEY (`IDPERSONA`) REFERENCES `persona` (`IDPERSONA`);

--
-- Constraints for table `venta`
--
ALTER TABLE `venta`
  ADD CONSTRAINT `fk_idmesa` FOREIGN KEY (`IDMESA`) REFERENCES `mesas` (`IDMESA`),
  ADD CONSTRAINT `fk_idusuario` FOREIGN KEY (`IDUSUARIO`) REFERENCES `usuarios` (`IDUSUARIO`);

--
-- Constraints for table `venta_bebidas`
--
ALTER TABLE `venta_bebidas`
  ADD CONSTRAINT `venta_bebidas_ibfk_1` FOREIGN KEY (`IDVENTA`) REFERENCES `venta` (`IDVENTA`),
  ADD CONSTRAINT `venta_bebidas_ibfk_2` FOREIGN KEY (`IDBEBIDAS`) REFERENCES `bebidas` (`IDBEBIDAS`);

--
-- Constraints for table `venta_postres`
--
ALTER TABLE `venta_postres`
  ADD CONSTRAINT `venta_postres_ibfk_1` FOREIGN KEY (`IDVENTA`) REFERENCES `venta` (`IDVENTA`),
  ADD CONSTRAINT `venta_postres_ibfk_2` FOREIGN KEY (`IDPOSTRES`) REFERENCES `postres` (`IDPOSTRES`);
COMMIT;

