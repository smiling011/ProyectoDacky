-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 27-04-2025 a las 04:04:42
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `dacky`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `ActualizarDispositivoGPS` (IN `p_IdDispositivoGPS` INT, IN `p_Mascota_IdMascota` INT)   BEGIN
    UPDATE dispositivogps
    SET Mascota_IdMascota = p_Mascota_IdMascota
    WHERE IdDispositivoGPS = p_IdDispositivoGPS;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ConsultarVacunasMascota` (IN `p_IdMascota` INT)   BEGIN
    SELECT v.NomVacuna
    FROM vacunasmascota vm
    JOIN vacunas v ON vm.Vacunas_IdVacunas = v.IdVacunas
    WHERE vm.Mascota_IdMascota = p_IdMascota;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `EliminarPerfilMascota` (IN `p_IdPerfilMascota` INT)   BEGIN
    DELETE FROM perfilmascota
    WHERE IdPerfilMascota = p_IdPerfilMascota;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarPerfilDueño` (IN `p_NomDueño` VARCHAR(100), IN `p_Apell` VARCHAR(100), IN `p_Email` VARCHAR(100), IN `p_NumTelf` BIGINT, IN `p_NumCel` BIGINT)   BEGIN
    INSERT INTO perfildueño (NomDueño, Apell, Email, NumTelf, NumCel)
    VALUES (p_NomDueño, p_Apell, p_Email, p_NumTelf, p_NumCel);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `RegistrarMascota` (IN `p_NumMascota` INT, IN `p_PerfilDueño_IdPerfilDueño` INT, IN `p_PerfilMascota_IdPerfilMascota` INT)   BEGIN
    INSERT INTO mascota (NumMascota, PerfilDueño_IdPerfilDueño, PerfilMascota_IdPerfilMascota)
    VALUES (p_NumMascota, p_PerfilDueño_IdPerfilDueño, p_PerfilMascota_IdPerfilMascota);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `RegistrarVacunaMascota` (IN `p_NomVacuna` VARCHAR(100), IN `p_Mascota_IdMascota` INT, IN `p_Vacunas_IdVacunas` INT)   BEGIN
    INSERT INTO vacunasmascota (NomVacuna, Mascota_IdMascota, Vacunas_IdVacunas)
    VALUES (p_NomVacuna, p_Mascota_IdMascota, p_Vacunas_IdVacunas);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `dispositivogps`
--

CREATE TABLE `dispositivogps` (
  `IdDispositivoGPS` int(11) NOT NULL,
  `Mascota_IdMascota` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `dispositivogps`
--

INSERT INTO `dispositivogps` (`IdDispositivoGPS`, `Mascota_IdMascota`) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `iniciosesion`
--

CREATE TABLE `iniciosesion` (
  `IdInicioSesion` int(11) NOT NULL,
  `Nom` varchar(100) NOT NULL,
  `Apell` varchar(100) CHARACTER SET armscii8 COLLATE armscii8_general_ci NOT NULL,
  `Email` varchar(200) NOT NULL,
  `Contrasena` varchar(255) NOT NULL,
  `NumTelf` bigint(12) NOT NULL,
  `NumCel` bigint(10) NOT NULL,
  `Direccion` text NOT NULL,
  `PerfilDueño_IdPerfilDueño` int(11) NOT NULL,
  `Rol` enum('admin','usuario') NOT NULL DEFAULT 'usuario'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `iniciosesion`
--

INSERT INTO `iniciosesion` (`IdInicioSesion`, `Nom`, `Apell`, `Email`, `Contrasena`, `NumTelf`, `NumCel`, `Direccion`, `PerfilDueño_IdPerfilDueño`, `Rol`) VALUES
(1, 'Juan', 'P?rez', 'juan.perez@mail.com', 'password1', 3112345678, 3001234567, 'Calle 123, Bogotá', 1, 'usuario'),
(2, 'María', 'Gonz?lez', 'maria.gonzalez@mail.com', 'password2', 3123456789, 3002345678, 'Carrera 456, Medellín', 2, 'usuario'),
(3, 'Carlos', 'Ram?rez', 'carlos.ramirez@mail.com', 'password3', 3134567890, 3003456789, 'Avenida 789, Cali', 3, 'usuario'),
(6, 'admin', 'admin', 'zorrarosa@hotmail.com', '1234567890', 1234567890, 123456790, 'Paris', 1, 'admin'),
(13, 'vicky', 'vielma', 'tqm1234@gmail.com', '1234', 1234567890, 0, 'qeqqeqe', 5, 'usuario'),
(14, 'tory', 'vielma', 'tory@gmail.com', '12344321', 1828162, 0, 'jbskjasbkJS', 6, 'usuario'),
(15, 'lily', 'romero', 'lily@gmail.com', '123445', 67890, 0, 'jslsdasldjalsdhlA', 7, 'usuario'),
(16, 'ojsnoASN09JASOI', '0IASJO', 'iAJSO@adhysad.com', 'ioasia', 0, 0, 'oASOa', 8, 'usuario'),
(17, 'Jose Manuel', 'Montes Taborda', 'iphone@gmail.com', 'putoelquelolea', 4376785, 0, 'calle 37 a 40', 9, 'usuario'),
(18, 'hola ', 'qtak', 'asajhs@gmail.com', '12345', 1234, 0, 'oASOa', 10, 'usuario'),
(19, 'guille', 'burgos', '123@gmail.com', '123456', 0, 0, 'skjdbkadbkja', 11, 'usuario'),
(20, 'prueba', 'cifrado', 'prueba@gmail.com', '1234', 231213, 0, '223fdfsd', 12, 'usuario'),
(21, 'contraseña', 'hihi', '1234prueba@gmail.com', 'pbkdf2:sha256:600000$9VMZ1uO1pXM9IrkH$7fb1f82577402d971b1a7cabc1f5b63a99256fa6dcfa4a24a363ad30ade13dbf', 23231, 0, 'ddasdadad3423', 13, 'usuario'),
(22, 'admin', 'admin ap', 'admin@gmail.com', 'pbkdf2:sha256:600000$yn8Ll9tdlCtq4HAS$106bbea86ef2deda0d250dbe46847cc6150ba5b283c7e3aa7c24a5df80639953', 123455432, 0, '121212hghfhg', 14, 'admin'),
(23, 'hola', 'que tal', 'hoa@gmail.com', 'pbkdf2:sha256:600000$3S5NUYqX3wxE34Mc$a9a595d11caf0949c0e272dd84c20dcb58fcdb2b5aed40d6483a874e01ae87fa', 1234567890, 0, 'jslsdasldjalsdhlA', 15, 'usuario');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `mascota`
--

CREATE TABLE `mascota` (
  `IdMascota` int(11) NOT NULL,
  `NumMascota` int(2) NOT NULL,
  `PerfilDueño_IdPerfilDueño` int(11) NOT NULL,
  `PerfilMascota_IdPerfilMascota` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `mascota`
--

INSERT INTO `mascota` (`IdMascota`, `NumMascota`, `PerfilDueño_IdPerfilDueño`, `PerfilMascota_IdPerfilMascota`) VALUES
(1, 1, 1, 1),
(2, 2, 2, 2),
(3, 3, 3, 3),
(4, 4, 4, 4);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `mascotaseliminadas`
--

CREATE TABLE `mascotaseliminadas` (
  `IdMascotaEliminada` int(11) NOT NULL,
  `IdMascota` int(11) DEFAULT NULL,
  `NomMascota` varchar(100) DEFAULT NULL,
  `Raza` varchar(100) DEFAULT NULL,
  `Edad` int(11) DEFAULT NULL,
  `Peso` decimal(10,0) DEFAULT NULL,
  `Altura` decimal(10,0) DEFAULT NULL,
  `Descripcion` text DEFAULT NULL,
  `FechaEliminacion` datetime DEFAULT current_timestamp(),
  `IdPerfilDueño` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `perfildueño`
--

CREATE TABLE `perfildueño` (
  `IdPerfilDueño` int(11) NOT NULL,
  `NomDueño` varchar(100) NOT NULL,
  `Apell` varchar(100) NOT NULL,
  `Email` varchar(100) NOT NULL,
  `NumTelf` bigint(12) NOT NULL,
  `NumCel` bigint(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `perfildueño`
--

INSERT INTO `perfildueño` (`IdPerfilDueño`, `NomDueño`, `Apell`, `Email`, `NumTelf`, `NumCel`) VALUES
(1, 'Juan', 'Pérez', 'juan.perez@mail.com', 3112345678, 3001234567),
(2, 'María', 'González', 'maria.gonzalez@mail.com', 3123456789, 3002345678),
(3, 'Carlos', 'Ramírez', 'carlos.ramirez@mail.com', 3134567890, 3003456789),
(4, 'Ana', 'Fernández', 'ana.fernandez@mail.com', 3145678901, 3004567890),
(5, 'vicky', 'vielma', 'tqm1234@gmail.com', 1234567890, 0),
(6, 'tory', 'vielma', 'tory@gmail.com', 1828162, 0),
(7, 'lily', 'romero', 'lily@gmail.com', 67890, 0),
(8, 'ojsnoASN09JASOI', '0IASJO', 'iAJSO@adhysad.com', 0, 0),
(9, 'Jose Manuel', 'Montes Taborda', 'iphone@gmail.com', 4376785, 0),
(10, 'hola ', 'qtak', 'asajhs@gmail.com', 1234, 0),
(11, 'guille', 'burgos', '123@gmail.com', 0, 0),
(12, 'prueba', 'cifrado', 'prueba@gmail.com', 231213, 0),
(13, 'contraseña', 'hihi', '1234prueba@gmail.com', 23231, 0),
(14, 'admin', 'admin ap', 'admin@gmail.com', 123455432, 0),
(15, 'hola', 'que tal', 'hoa@gmail.com', 1234567890, 0),
(16, 'hola', 'vielma', 'hjahajsh@gmail.com', 1234, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `perfilmascota`
--

CREATE TABLE `perfilmascota` (
  `IdPerfilMascota` int(11) NOT NULL,
  `NomMascota` varchar(100) NOT NULL,
  `Raza` varchar(100) NOT NULL,
  `Peso` decimal(10,0) NOT NULL,
  `Altura` decimal(10,0) NOT NULL,
  `Descripcion` text NOT NULL,
  `Edad` int(2) NOT NULL,
  `PerfilDueño_IdPerfilDueño` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `perfilmascota`
--

INSERT INTO `perfilmascota` (`IdPerfilMascota`, `NomMascota`, `Raza`, `Peso`, `Altura`, `Descripcion`, `Edad`, `PerfilDueño_IdPerfilDueño`) VALUES
(1, 'Max', 'Labrador', 31, 60, 'Perro muy amigable', 5, 1),
(2, 'Bella', 'Golden Retriever', 28, 55, 'Mascota juguetona', 3, 2),
(3, 'Rocky', 'Bulldog', 25, 50, 'Perro de compañía', 4, 3),
(4, 'Luna', 'Beagle', 12, 40, 'Perra curiosa y activa', 2, 4);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `raza`
--

CREATE TABLE `raza` (
  `IdRaza` int(11) NOT NULL,
  `NomRaza` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `raza`
--

INSERT INTO `raza` (`IdRaza`, `NomRaza`) VALUES
(1, 'Labrador'),
(2, 'Golden Retriever'),
(3, 'Bulldog'),
(4, 'Beagle');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `razamascota`
--

CREATE TABLE `razamascota` (
  `IdRazaMascota` int(11) NOT NULL,
  `NomRaza` varchar(100) NOT NULL,
  `Mascota_IdMascota` int(11) NOT NULL,
  `Raza_IdRaza` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `razamascota`
--

INSERT INTO `razamascota` (`IdRazaMascota`, `NomRaza`, `Mascota_IdMascota`, `Raza_IdRaza`) VALUES
(1, 'Labrador', 1, 1),
(2, 'Golden Retriever', 2, 2),
(3, 'Bulldog', 3, 3),
(4, 'Beagle', 4, 4);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `vacunas`
--

CREATE TABLE `vacunas` (
  `IdVacunas` int(11) NOT NULL,
  `NomVacuna` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `vacunas`
--

INSERT INTO `vacunas` (`IdVacunas`, `NomVacuna`) VALUES
(1, 'Rabia'),
(2, 'Parvovirus'),
(3, 'Moquillo'),
(4, 'Hepatitis');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `vacunasmascota`
--

CREATE TABLE `vacunasmascota` (
  `IdVacunasMascota` int(11) NOT NULL,
  `NomVacuna` varchar(100) NOT NULL,
  `Mascota_IdMascota` int(11) NOT NULL,
  `Vacunas_IdVacunas` int(11) NOT NULL,
  `FechaVac` date DEFAULT NULL,
  `Edad` int(11) NOT NULL,
  `FechaVenVac` date DEFAULT NULL,
  `NumDosis` int(11) NOT NULL,
  `Nota` text DEFAULT NULL,
  `Img` blob DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `vacunasmascota`
--

INSERT INTO `vacunasmascota` (`IdVacunasMascota`, `NomVacuna`, `Mascota_IdMascota`, `Vacunas_IdVacunas`, `FechaVac`, `Edad`, `FechaVenVac`, `NumDosis`, `Nota`, `Img`) VALUES
(1, 'Rabia', 1, 1, NULL, 0, NULL, 0, NULL, NULL),
(2, 'Parvovirus', 2, 2, NULL, 0, NULL, 0, NULL, NULL),
(3, 'Moquillo', 3, 3, NULL, 0, NULL, 0, NULL, NULL),
(4, 'Hepatitis', 4, 4, NULL, 0, NULL, 0, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_detalles_mascota`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_detalles_mascota` (
`NomMascota` varchar(100)
,`Raza` varchar(100)
,`Peso` decimal(10,0)
,`Altura` decimal(10,0)
,`Descripcion` text
,`Edad` int(2)
,`NomDueño` varchar(100)
,`Apell` varchar(100)
,`NomVacuna` varchar(100)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_dueños_mascotas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_dueños_mascotas` (
`NomDueño` varchar(100)
,`Apell` varchar(100)
,`CantidadMascotas` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_iniciosesion_dueño`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_iniciosesion_dueño` (
`Nom` varchar(100)
,`Apell` varchar(100)
,`Email` varchar(200)
,`NumTelf` bigint(12)
,`NumCel` bigint(10)
,`NomDueño` varchar(100)
,`ApellidoDueño` varchar(100)
,`EmailDueño` varchar(100)
,`TelfDueño` bigint(12)
,`CelDueño` bigint(10)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_mascotas_dueños`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_mascotas_dueños` (
`IdMascota` int(11)
,`NumMascota` int(2)
,`NomMascota` varchar(100)
,`Raza` varchar(100)
,`Peso` decimal(10,0)
,`Altura` decimal(10,0)
,`Descripcion` text
,`Edad` int(2)
,`NomDueño` varchar(100)
,`Apell` varchar(100)
,`Email` varchar(100)
,`NumTelf` bigint(12)
,`NumCel` bigint(10)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_mascotas_gps`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_mascotas_gps` (
`IdDispositivoGPS` int(11)
,`NomMascota` varchar(100)
,`Raza` varchar(100)
,`Edad` int(2)
,`NomDueño` varchar(100)
,`Apell` varchar(100)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_mascotas_razas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_mascotas_razas` (
`NomMascota` varchar(100)
,`NomRaza` varchar(100)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_vacunas_mascotas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_vacunas_mascotas` (
`NomMascota` varchar(100)
,`Raza` varchar(100)
,`NomVacuna` varchar(100)
);

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_detalles_mascota`
--
DROP TABLE IF EXISTS `vista_detalles_mascota`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_detalles_mascota`  AS SELECT `perfilmascota`.`NomMascota` AS `NomMascota`, `perfilmascota`.`Raza` AS `Raza`, `perfilmascota`.`Peso` AS `Peso`, `perfilmascota`.`Altura` AS `Altura`, `perfilmascota`.`Descripcion` AS `Descripcion`, `perfilmascota`.`Edad` AS `Edad`, `perfildueño`.`NomDueño` AS `NomDueño`, `perfildueño`.`Apell` AS `Apell`, `vacunas`.`NomVacuna` AS `NomVacuna` FROM ((((`mascota` join `perfilmascota` on(`mascota`.`PerfilMascota_IdPerfilMascota` = `perfilmascota`.`IdPerfilMascota`)) join `perfildueño` on(`mascota`.`PerfilDueño_IdPerfilDueño` = `perfildueño`.`IdPerfilDueño`)) left join `vacunasmascota` on(`vacunasmascota`.`Mascota_IdMascota` = `mascota`.`IdMascota`)) left join `vacunas` on(`vacunasmascota`.`Vacunas_IdVacunas` = `vacunas`.`IdVacunas`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_dueños_mascotas`
--
DROP TABLE IF EXISTS `vista_dueños_mascotas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_dueños_mascotas`  AS SELECT `perfildueño`.`NomDueño` AS `NomDueño`, `perfildueño`.`Apell` AS `Apell`, count(`mascota`.`IdMascota`) AS `CantidadMascotas` FROM (`perfildueño` join `mascota` on(`mascota`.`PerfilDueño_IdPerfilDueño` = `perfildueño`.`IdPerfilDueño`)) GROUP BY `perfildueño`.`IdPerfilDueño` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_iniciosesion_dueño`
--
DROP TABLE IF EXISTS `vista_iniciosesion_dueño`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_iniciosesion_dueño`  AS SELECT `iniciosesion`.`Nom` AS `Nom`, `iniciosesion`.`Apell` AS `Apell`, `iniciosesion`.`Email` AS `Email`, `iniciosesion`.`NumTelf` AS `NumTelf`, `iniciosesion`.`NumCel` AS `NumCel`, `perfildueño`.`NomDueño` AS `NomDueño`, `perfildueño`.`Apell` AS `ApellidoDueño`, `perfildueño`.`Email` AS `EmailDueño`, `perfildueño`.`NumTelf` AS `TelfDueño`, `perfildueño`.`NumCel` AS `CelDueño` FROM (`iniciosesion` join `perfildueño` on(`iniciosesion`.`PerfilDueño_IdPerfilDueño` = `perfildueño`.`IdPerfilDueño`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_mascotas_dueños`
--
DROP TABLE IF EXISTS `vista_mascotas_dueños`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_mascotas_dueños`  AS SELECT `mascota`.`IdMascota` AS `IdMascota`, `mascota`.`NumMascota` AS `NumMascota`, `perfilmascota`.`NomMascota` AS `NomMascota`, `perfilmascota`.`Raza` AS `Raza`, `perfilmascota`.`Peso` AS `Peso`, `perfilmascota`.`Altura` AS `Altura`, `perfilmascota`.`Descripcion` AS `Descripcion`, `perfilmascota`.`Edad` AS `Edad`, `perfildueño`.`NomDueño` AS `NomDueño`, `perfildueño`.`Apell` AS `Apell`, `perfildueño`.`Email` AS `Email`, `perfildueño`.`NumTelf` AS `NumTelf`, `perfildueño`.`NumCel` AS `NumCel` FROM ((`mascota` join `perfilmascota` on(`mascota`.`PerfilMascota_IdPerfilMascota` = `perfilmascota`.`IdPerfilMascota`)) join `perfildueño` on(`mascota`.`PerfilDueño_IdPerfilDueño` = `perfildueño`.`IdPerfilDueño`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_mascotas_gps`
--
DROP TABLE IF EXISTS `vista_mascotas_gps`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_mascotas_gps`  AS SELECT `dispositivo`.`IdDispositivoGPS` AS `IdDispositivoGPS`, `perfilmascota`.`NomMascota` AS `NomMascota`, `perfilmascota`.`Raza` AS `Raza`, `perfilmascota`.`Edad` AS `Edad`, `perfildueño`.`NomDueño` AS `NomDueño`, `perfildueño`.`Apell` AS `Apell` FROM (((`dispositivogps` `dispositivo` join `mascota` on(`dispositivo`.`Mascota_IdMascota` = `mascota`.`IdMascota`)) join `perfilmascota` on(`mascota`.`PerfilMascota_IdPerfilMascota` = `perfilmascota`.`IdPerfilMascota`)) join `perfildueño` on(`mascota`.`PerfilDueño_IdPerfilDueño` = `perfildueño`.`IdPerfilDueño`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_mascotas_razas`
--
DROP TABLE IF EXISTS `vista_mascotas_razas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_mascotas_razas`  AS SELECT `perfilmascota`.`NomMascota` AS `NomMascota`, `razamascota`.`NomRaza` AS `NomRaza` FROM ((`perfilmascota` join `razamascota` on(`perfilmascota`.`IdPerfilMascota` = `razamascota`.`Mascota_IdMascota`)) join `raza` on(`razamascota`.`Raza_IdRaza` = `raza`.`IdRaza`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_vacunas_mascotas`
--
DROP TABLE IF EXISTS `vista_vacunas_mascotas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_vacunas_mascotas`  AS SELECT `perfilmascota`.`NomMascota` AS `NomMascota`, `perfilmascota`.`Raza` AS `Raza`, `vacunas`.`NomVacuna` AS `NomVacuna` FROM (((`vacunasmascota` join `mascota` on(`vacunasmascota`.`Mascota_IdMascota` = `mascota`.`IdMascota`)) join `perfilmascota` on(`mascota`.`PerfilMascota_IdPerfilMascota` = `perfilmascota`.`IdPerfilMascota`)) join `vacunas` on(`vacunasmascota`.`Vacunas_IdVacunas` = `vacunas`.`IdVacunas`)) ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `dispositivogps`
--
ALTER TABLE `dispositivogps`
  ADD PRIMARY KEY (`IdDispositivoGPS`),
  ADD KEY `Mascota_IdMascota` (`Mascota_IdMascota`);

--
-- Indices de la tabla `iniciosesion`
--
ALTER TABLE `iniciosesion`
  ADD PRIMARY KEY (`IdInicioSesion`),
  ADD KEY `PerfilDueño_IdPerfilDueño` (`PerfilDueño_IdPerfilDueño`);

--
-- Indices de la tabla `mascota`
--
ALTER TABLE `mascota`
  ADD PRIMARY KEY (`IdMascota`),
  ADD KEY `PerfilDueño_IdPerfilDueño` (`PerfilDueño_IdPerfilDueño`),
  ADD KEY `PerfilMascota_IdPerfilMascota` (`PerfilMascota_IdPerfilMascota`);

--
-- Indices de la tabla `mascotaseliminadas`
--
ALTER TABLE `mascotaseliminadas`
  ADD PRIMARY KEY (`IdMascotaEliminada`),
  ADD KEY `IdPerfilDueño` (`IdPerfilDueño`);

--
-- Indices de la tabla `perfildueño`
--
ALTER TABLE `perfildueño`
  ADD PRIMARY KEY (`IdPerfilDueño`);

--
-- Indices de la tabla `perfilmascota`
--
ALTER TABLE `perfilmascota`
  ADD PRIMARY KEY (`IdPerfilMascota`),
  ADD KEY `PerfilDueño_IdPerfilDueño` (`PerfilDueño_IdPerfilDueño`);

--
-- Indices de la tabla `raza`
--
ALTER TABLE `raza`
  ADD PRIMARY KEY (`IdRaza`);

--
-- Indices de la tabla `razamascota`
--
ALTER TABLE `razamascota`
  ADD PRIMARY KEY (`IdRazaMascota`),
  ADD KEY `Mascota_IdMascota` (`Mascota_IdMascota`),
  ADD KEY `Raza_IdRaza` (`Raza_IdRaza`);

--
-- Indices de la tabla `vacunas`
--
ALTER TABLE `vacunas`
  ADD PRIMARY KEY (`IdVacunas`);

--
-- Indices de la tabla `vacunasmascota`
--
ALTER TABLE `vacunasmascota`
  ADD PRIMARY KEY (`IdVacunasMascota`),
  ADD KEY `Mascota_IdMascota` (`Mascota_IdMascota`),
  ADD KEY `Vacunas_IdVacunas` (`Vacunas_IdVacunas`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `dispositivogps`
--
ALTER TABLE `dispositivogps`
  MODIFY `IdDispositivoGPS` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `iniciosesion`
--
ALTER TABLE `iniciosesion`
  MODIFY `IdInicioSesion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT de la tabla `mascota`
--
ALTER TABLE `mascota`
  MODIFY `IdMascota` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `mascotaseliminadas`
--
ALTER TABLE `mascotaseliminadas`
  MODIFY `IdMascotaEliminada` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `perfildueño`
--
ALTER TABLE `perfildueño`
  MODIFY `IdPerfilDueño` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT de la tabla `perfilmascota`
--
ALTER TABLE `perfilmascota`
  MODIFY `IdPerfilMascota` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `raza`
--
ALTER TABLE `raza`
  MODIFY `IdRaza` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `razamascota`
--
ALTER TABLE `razamascota`
  MODIFY `IdRazaMascota` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `vacunas`
--
ALTER TABLE `vacunas`
  MODIFY `IdVacunas` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `vacunasmascota`
--
ALTER TABLE `vacunasmascota`
  MODIFY `IdVacunasMascota` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `dispositivogps`
--
ALTER TABLE `dispositivogps`
  ADD CONSTRAINT `dispositivogps_ibfk_1` FOREIGN KEY (`Mascota_IdMascota`) REFERENCES `mascota` (`IdMascota`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `iniciosesion`
--
ALTER TABLE `iniciosesion`
  ADD CONSTRAINT `iniciosesion_ibfk_1` FOREIGN KEY (`PerfilDueño_IdPerfilDueño`) REFERENCES `perfildueño` (`IdPerfilDueño`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `mascota`
--
ALTER TABLE `mascota`
  ADD CONSTRAINT `mascota_ibfk_1` FOREIGN KEY (`PerfilDueño_IdPerfilDueño`) REFERENCES `perfildueño` (`IdPerfilDueño`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `mascota_ibfk_2` FOREIGN KEY (`PerfilMascota_IdPerfilMascota`) REFERENCES `perfilmascota` (`IdPerfilMascota`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `mascotaseliminadas`
--
ALTER TABLE `mascotaseliminadas`
  ADD CONSTRAINT `mascotaseliminadas_ibfk_1` FOREIGN KEY (`IdPerfilDueño`) REFERENCES `perfildueño` (`IdPerfilDueño`);

--
-- Filtros para la tabla `perfilmascota`
--
ALTER TABLE `perfilmascota`
  ADD CONSTRAINT `perfilmascota_ibfk_1` FOREIGN KEY (`PerfilDueño_IdPerfilDueño`) REFERENCES `perfildueño` (`IdPerfilDueño`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `razamascota`
--
ALTER TABLE `razamascota`
  ADD CONSTRAINT `razamascota_ibfk_1` FOREIGN KEY (`Mascota_IdMascota`) REFERENCES `mascota` (`IdMascota`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `razamascota_ibfk_2` FOREIGN KEY (`Raza_IdRaza`) REFERENCES `raza` (`IdRaza`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `vacunasmascota`
--
ALTER TABLE `vacunasmascota`
  ADD CONSTRAINT `vacunasmascota_ibfk_1` FOREIGN KEY (`Mascota_IdMascota`) REFERENCES `mascota` (`IdMascota`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `vacunasmascota_ibfk_2` FOREIGN KEY (`Vacunas_IdVacunas`) REFERENCES `vacunas` (`IdVacunas`) ON DELETE NO ACTION ON UPDATE NO ACTION;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
