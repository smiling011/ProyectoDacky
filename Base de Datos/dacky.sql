-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 22-06-2024 a las 02:43:02
-- Versión del servidor: 10.4.28-MariaDB
-- Versión de PHP: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `dacky`
CREATE DATABASE dacky;
use dacky;
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `dispositivogps`
--

CREATE TABLE `dispositivogps` (
  `IdDispositivoGPS` int(11) NOT NULL,
  `Mascota_IdMascota` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `iniciosesion`
--

CREATE TABLE `iniciosesion` (
  `IdInicioSesion` int(11) NOT NULL,
  `Nom` varchar(100) NOT NULL,
  `Apell` varchar(100) CHARACTER SET armscii8 COLLATE armscii8_general_ci NOT NULL,
  `Email` varchar(200) NOT NULL,
  `Contrasena` varchar(100) NOT NULL,
  `NumTelf` bigint(12) NOT NULL,
  `NumCel` bigint(10) NOT NULL,
  `Direccion` text NOT NULL,
  `PerfilDueño_IdPerfilDueño` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

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

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `raza`
--

CREATE TABLE `raza` (
  `IdRaza` int(11) NOT NULL,
  `NomRaza` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

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

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `vacunas`
--

CREATE TABLE `vacunas` (
  `IdVacunas` int(11) NOT NULL,
  `NomVacuna` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `vacunasmascota`
--

CREATE TABLE `vacunasmascota` (
  `IdVacunasMascota` int(11) NOT NULL,
  `NomVacuna` varchar(100) NOT NULL,
  `Mascota_IdMascota` int(11) NOT NULL,
  `Vacunas_IdVacunas` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

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
  MODIFY `IdDispositivoGPS` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `iniciosesion`
--
ALTER TABLE `iniciosesion`
  MODIFY `IdInicioSesion` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `mascota`
--
ALTER TABLE `mascota`
  MODIFY `IdMascota` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `perfildueño`
--
ALTER TABLE `perfildueño`
  MODIFY `IdPerfilDueño` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `perfilmascota`
--
ALTER TABLE `perfilmascota`
  MODIFY `IdPerfilMascota` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `raza`
--
ALTER TABLE `raza`
  MODIFY `IdRaza` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `razamascota`
--
ALTER TABLE `razamascota`
  MODIFY `IdRazaMascota` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `vacunas`
--
ALTER TABLE `vacunas`
  MODIFY `IdVacunas` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `vacunasmascota`
--
ALTER TABLE `vacunasmascota`
  MODIFY `IdVacunasMascota` int(11) NOT NULL AUTO_INCREMENT;

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
