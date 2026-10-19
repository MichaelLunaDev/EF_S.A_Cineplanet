/* =====================================================================
   BD_CineplanetFinal - EVALUACIÓN FINAL · Seguridad de Aplicaciones (SQL Server)
   Ejecutar completo en SSMS (Ctrl+A, F5).
   ===================================================================== */
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;   -- requerido por el indice filtrado UX_Entrada_Butaca
GO
IF DB_ID('BD_CineplanetFinal') IS NOT NULL
BEGIN
    ALTER DATABASE BD_CineplanetFinal SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE BD_CineplanetFinal;
END
GO
CREATE DATABASE BD_CineplanetFinal;
GO
USE BD_CineplanetFinal;
GO

CREATE TABLE Usuario (
    idUsuario INT IDENTITY(1,1) PRIMARY KEY,
    usuario   VARCHAR(30) NOT NULL UNIQUE,
    clave     VARCHAR(30) NOT NULL,
    nombre    VARCHAR(60) NOT NULL
);

CREATE TABLE Cliente (
    idCliente INT IDENTITY(1,1) PRIMARY KEY,
    dni       CHAR(8)     NOT NULL UNIQUE,
    nombres   VARCHAR(60) NOT NULL,
    apellidos VARCHAR(60) NOT NULL,
    correo    VARCHAR(80) NULL,
    telefono  VARCHAR(15) NULL,
    clave     VARCHAR(30) NOT NULL DEFAULT 'cliente123'   -- acceso del cliente a "Mis entradas" (DNI + clave)
);

CREATE TABLE Pelicula (
    idPelicula    INT IDENTITY(1,1) PRIMARY KEY,
    titulo        VARCHAR(80) NOT NULL,
    genero        VARCHAR(30) NOT NULL,
    duracionMin   INT         NOT NULL CHECK (duracionMin > 0),
    clasificacion VARCHAR(10) NOT NULL CHECK (clasificacion IN ('APT','+14','+18')),
    estado        VARCHAR(15) NOT NULL DEFAULT 'CARTELERA' CHECK (estado IN ('CARTELERA','PROXIMAMENTE'))
);

CREATE TABLE Funcion (
    idFuncion          INT IDENTITY(1,1) PRIMARY KEY,
    idPelicula         INT           NOT NULL REFERENCES Pelicula(idPelicula),
    sala               INT           NOT NULL CHECK (sala BETWEEN 1 AND 20),
    fechaHora          DATETIME      NOT NULL,
    precio             DECIMAL(8,2)  NOT NULL CHECK (precio > 0),
    butacasTotales     INT           NOT NULL CHECK (butacasTotales BETWEEN 1 AND 120),
    butacasDisponibles INT           NOT NULL CHECK (butacasDisponibles >= 0)
);

CREATE TABLE Entrada (
    idEntrada    INT IDENTITY(1,1) PRIMARY KEY,
    idCliente    INT          NOT NULL REFERENCES Cliente(idCliente),
    idFuncion    INT          NOT NULL REFERENCES Funcion(idFuncion),
    butaca       VARCHAR(3)   NOT NULL,                    -- fila A-J + número 1-12 (ej. F7)
    fechaVenta   DATETIME     NOT NULL DEFAULT GETDATE(),
    precioPagado DECIMAL(8,2) NOT NULL,
    estado       VARCHAR(10)  NOT NULL DEFAULT 'ACTIVA' CHECK (estado IN ('ACTIVA','ANULADA'))
);
-- Una butaca no puede venderse dos veces en la misma función (solo entradas activas)
CREATE UNIQUE INDEX UX_Entrada_Butaca ON Entrada(idFuncion, butaca) WHERE estado = 'ACTIVA';
GO

/* ---------------- Datos de prueba ---------------- */
INSERT INTO Usuario (usuario, clave, nombre) VALUES
('cajero', 'cajero123', 'Cajero Principal'),
('admin',  'admin123',  'Administrador del Cine');

INSERT INTO Cliente (dni, nombres, apellidos, correo, telefono) VALUES
('45678123', 'Carlos',  'Mendoza Rojas',  'carlos.mendoza@mail.com', '987654321'),
('41237894', 'Lucía',   'Paredes Vega',   'lucia.paredes@mail.com',  '976543210'),
('70123456', 'Jorge',   'Salazar Quispe', 'jorge.salazar@mail.com',  '965432109'),
('72345678', 'Andrea',  'Torres Díaz',    'andrea.torres@mail.com',  '954321098'),
('46789012', 'Miguel',  'Huamán Castro',  'miguel.huaman@mail.com',  '943210987'),
('43210987', 'Valeria', 'Ramos Flores',   'valeria.ramos@mail.com',  '932109876');

INSERT INTO Pelicula (titulo, genero, duracionMin, clasificacion, estado) VALUES
('La Última Función',      'Drama',    118, '+14', 'CARTELERA'),
('Aventura en los Andes',  'Aventura', 105, 'APT', 'CARTELERA'),
('Misterio en Lima',       'Suspenso', 112, '+14', 'CARTELERA'),
('Galaxia Cero',           'Ciencia ficción', 130, '+14', 'CARTELERA'),
('Risas en Familia',       'Comedia',   96, 'APT', 'PROXIMAMENTE');

INSERT INTO Funcion (idPelicula, sala, fechaHora, precio, butacasTotales, butacasDisponibles) VALUES
(1, 1, '2026-11-20T18:30:00', 24.90, 100,  98),
(2, 2, '2026-11-20T16:00:00', 19.90,  80,  80),
(3, 3, '2026-11-20T21:00:00', 24.90,  90,  89),
(4, 4, '2026-11-21T20:15:00', 29.90, 120, 120),
(1, 1, '2026-11-21T21:15:00', 24.90, 100, 100),
(2, 2, '2026-11-22T15:30:00', 19.90,  80,  80),
(3, 3, '2026-11-22T19:45:00', 24.90,  90,  90);

-- 3 entradas activas (las butacas disponibles de las funciones 1 y 3 ya están descontadas)
INSERT INTO Entrada (idCliente, idFuncion, butaca, precioPagado) VALUES
(1, 1, 'F7', 24.90),
(2, 1, 'F8', 24.90),
(3, 3, 'C5', 24.90);
GO

/* ---------------- Consultas de verificación ---------------- */
SELECT f.idFuncion, p.titulo, f.sala, f.fechaHora, f.precio, f.butacasDisponibles
FROM Funcion f JOIN Pelicula p ON p.idPelicula = f.idPelicula;

SELECT e.idEntrada, c.nombres + ' ' + c.apellidos AS cliente, p.titulo, f.sala, e.butaca, e.precioPagado, e.estado
FROM Entrada e
JOIN Cliente c  ON c.idCliente  = e.idCliente
JOIN Funcion f  ON f.idFuncion  = e.idFuncion
JOIN Pelicula p ON p.idPelicula = f.idPelicula;

GO
/* =====================================================================
   BD_CineplanetFinal - PARTE 2: Carrito de compras (entradas + dulcería)
                           y datos masivos para el dashboard en Power BI
   ---------------------------------------------------------------------
   1) Ejecutar primero  BD_CineplanetFinal.sql   (crea la BD base)
   2) Ejecutar este script completo (Ctrl+A, F5). Tarda ~1 minuto.

   Agrega: Sede, Producto (dulcería), Venta (cabecera del carrito),
   DetalleVenta (productos), MetaMensual, Calendario y las vistas vw_*
   que lee Power BI. Genera 12 meses de historia HASTA EL DÍA DE HOY,
   así el dashboard siempre se ve "actual" sin importar cuándo se corra.
   ===================================================================== */
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET NOCOUNT ON;
GO
USE BD_CineplanetFinal;
GO
IF OBJECT_ID('dbo.Venta') IS NOT NULL
BEGIN
    RAISERROR('La parte 2 ya fue ejecutada. Vuelva a correr BD_CineplanetFinal.sql y luego este script.', 16, 1);
    SET NOEXEC ON;   -- no ejecuta el resto del script
END
GO

/* =====================================================================
   1. TABLAS NUEVAS
   ===================================================================== */
CREATE TABLE Sede (
    idSede INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(60) NOT NULL,
    ciudad VARCHAR(40) NOT NULL,
    region VARCHAR(20) NOT NULL CHECK (region IN ('Lima','Norte','Sur')),
    salas  INT         NOT NULL
);
INSERT INTO Sede (nombre, ciudad, region, salas) VALUES
('Cineplanet Alcázar',     'Lima',     'Lima',  4),
('Cineplanet San Miguel',  'Lima',     'Lima',  4),
('Cineplanet Primavera',   'Lima',     'Lima',  4),
('Cineplanet Mall del Sur','Lima',     'Lima',  4),
('Cineplanet Trujillo',    'Trujillo', 'Norte', 4),
('Cineplanet Piura',       'Piura',    'Norte', 4),
('Cineplanet Arequipa',    'Arequipa', 'Sur',   4),
('Cineplanet Cusco',       'Cusco',    'Sur',   4);
GO
-- Cada función pertenece a una sede (las funciones ya existentes quedan en la sede 1)
ALTER TABLE Funcion ADD idSede INT NOT NULL CONSTRAINT DF_Funcion_Sede DEFAULT 1
                        CONSTRAINT FK_Funcion_Sede REFERENCES Sede(idSede);
ALTER TABLE Pelicula ADD fechaEstreno DATE NULL;
ALTER TABLE Cliente  ADD sexo CHAR(1) NULL, fechaNacimiento DATE NULL,
                         fechaRegistro DATE NULL CONSTRAINT DF_Cliente_Registro DEFAULT GETDATE();
GO

CREATE TABLE Producto (
    idProducto INT IDENTITY(1,1) PRIMARY KEY,
    nombre     VARCHAR(60)  NOT NULL,
    categoria  VARCHAR(15)  NOT NULL CHECK (categoria IN ('COMBO','CANCHITA','BEBIDA','SNACK','DULCE')),
    precio     DECIMAL(8,2) NOT NULL CHECK (precio > 0),
    costo      DECIMAL(8,2) NOT NULL CHECK (costo >= 0),
    activo     BIT          NOT NULL DEFAULT 1
);

-- Cabecera de la compra (lo que el cliente paga al confirmar su carrito)
CREATE TABLE Venta (
    idVenta    INT IDENTITY(1,1) PRIMARY KEY,
    idCliente  INT           NOT NULL REFERENCES Cliente(idCliente),
    idSede     INT           NOT NULL REFERENCES Sede(idSede),
    fechaVenta DATETIME      NOT NULL DEFAULT GETDATE(),
    canal      VARCHAR(10)   NOT NULL CHECK (canal IN ('WEB','APP','BOLETERIA')),
    medioPago  VARCHAR(10)   NOT NULL CHECK (medioPago IN ('TARJETA','YAPE','PLIN','EFECTIVO')),
    total      DECIMAL(10,2) NOT NULL DEFAULT 0,
    estado     VARCHAR(10)   NOT NULL DEFAULT 'PAGADA' CHECK (estado IN ('PAGADA','ANULADA'))
);
-- Las entradas del carrito apuntan a su venta (NULL = vendidas antes de existir el carrito)
ALTER TABLE Entrada ADD idVenta INT NULL CONSTRAINT FK_Entrada_Venta REFERENCES Venta(idVenta);

-- Productos de dulcería comprados en la venta
CREATE TABLE DetalleVenta (
    idDetalle  INT IDENTITY(1,1) PRIMARY KEY,
    idVenta    INT          NOT NULL REFERENCES Venta(idVenta),
    idProducto INT          NOT NULL REFERENCES Producto(idProducto),
    cantidad   INT          NOT NULL CHECK (cantidad > 0),
    precioUnit DECIMAL(8,2) NOT NULL,
    subtotal   AS CAST(cantidad * precioUnit AS DECIMAL(10,2)) PERSISTED
);

-- Meta de ingresos por sede y mes (para el % de cumplimiento del dashboard)
CREATE TABLE MetaMensual (
    idSede     INT           NOT NULL REFERENCES Sede(idSede),
    anio       INT           NOT NULL,
    mes        INT           NOT NULL CHECK (mes BETWEEN 1 AND 12),
    metaVentas DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (idSede, anio, mes)
);

-- Tabla calendario (dimensión de tiempo para Power BI)
CREATE TABLE Calendario (
    fecha        DATE        PRIMARY KEY,
    anio         INT         NOT NULL,
    mes          INT         NOT NULL,
    nombreMes    VARCHAR(12) NOT NULL,
    mesCorto     VARCHAR(8)  NOT NULL,   -- "Ene 26"
    anioMes      INT         NOT NULL,   -- 202601 (para ordenar)
    trimestre    VARCHAR(2)  NOT NULL,
    diaSemana    INT         NOT NULL,   -- 1 = lunes ... 7 = domingo
    nombreDia    VARCHAR(10) NOT NULL,
    finDeSemana  VARCHAR(2)  NOT NULL    -- 'Sí' / 'No'
);
CREATE INDEX IX_Venta_Fecha    ON Venta(fechaVenta);
CREATE INDEX IX_Entrada_Venta  ON Entrada(idVenta);
CREATE INDEX IX_Detalle_Venta  ON DetalleVenta(idVenta);
CREATE INDEX IX_Funcion_Fecha  ON Funcion(fechaHora);
GO

/* =====================================================================
   2. CATÁLOGOS: dulcería, películas y clientes
   ===================================================================== */
INSERT INTO Producto (nombre, categoria, precio, costo) VALUES
('Combo Clásico',            'COMBO',    32.90,  9.50),
('Combo Pareja',             'COMBO',    39.90, 12.00),
('Combo Familiar',           'COMBO',    54.90, 16.50),
('Combo Kids',               'COMBO',    19.90,  6.20),
('Canchita Salada Mediana',  'CANCHITA', 14.90,  3.10),
('Canchita Salada Grande',   'CANCHITA', 18.90,  3.90),
('Canchita Dulce Grande',    'CANCHITA', 20.90,  4.40),
('Canchita Mix Grande',      'CANCHITA', 21.90,  4.60),
('Gaseosa Mediana',          'BEBIDA',    9.90,  2.10),
('Gaseosa Grande',           'BEBIDA',   11.90,  2.60),
('Agua Mineral',             'BEBIDA',    6.50,  1.40),
('Frappé de Café',           'BEBIDA',   13.90,  4.20),
('Hot Dog Clásico',          'SNACK',    12.90,  4.10),
('Nachos con Queso',         'SNACK',    16.90,  5.30),
('Chocolate con Maní',       'DULCE',     4.50,  1.90),
('Gomitas Surtidas',         'DULCE',     6.90,  2.40);

INSERT INTO Pelicula (titulo, genero, duracionMin, clasificacion, estado) VALUES
('Furia en el Pacífico',  'Acción',          124, '+14', 'CARTELERA'),
('El Guardián del Sol',   'Animación',        98, 'APT', 'CARTELERA'),
('Noches de Barranco',    'Romance',         108, '+14', 'CARTELERA'),
('Código Inca',           'Acción',          117, '+14', 'CARTELERA'),
('La Casa del Cerro',     'Terror',          101, '+18', 'CARTELERA'),
('Pequeños Héroes',       'Animación',        94, 'APT', 'CARTELERA'),
('Operación Amazonas',    'Aventura',        126, '+14', 'CARTELERA'),
('El Último Penal',       'Drama',           122, '+14', 'CARTELERA'),
('Susurros',              'Terror',           99, '+18', 'CARTELERA'),
('Planeta Rojo 2',        'Ciencia ficción', 138, '+14', 'CARTELERA'),
('Mi Abuela es Espía',    'Comedia',          97, 'APT', 'CARTELERA'),
('Ritmo Criollo',         'Musical',         111, 'APT', 'CARTELERA'),
('Sombras de Cusco',      'Suspenso',        115, '+14', 'CARTELERA'),
('Velocidad Total',       'Acción',          129, '+14', 'CARTELERA'),
('El Rey de la Selva',    'Animación',       102, 'APT', 'CARTELERA'),
('Corazones en Juego',    'Romance',         104, 'APT', 'CARTELERA'),
('Leyendas del Ande',     'Aventura',        119, 'APT', 'CARTELERA'),
('Medianoche en Lima',    'Terror',           96, '+18', 'CARTELERA');
GO

DECLARE @hoy DATE = CAST(GETDATE() AS DATE);

-- Estrenos: las 18 nuevas cada 3 semanas a lo largo del último año; las 4 originales, recientes
UPDATE Pelicula SET fechaEstreno = DATEADD(DAY, -380 + (idPelicula - 6) * 21, @hoy) WHERE idPelicula >= 6;
UPDATE Pelicula SET fechaEstreno = DATEADD(DAY, CASE idPelicula WHEN 1 THEN -18 WHEN 2 THEN -25
                                                 WHEN 3 THEN -11 WHEN 4 THEN -4 ELSE 30 END, @hoy)
WHERE idPelicula <= 5;
-- Solo siguen en cartelera las estrenadas hace menos de 8 semanas
UPDATE Pelicula SET estado = CASE WHEN fechaEstreno > @hoy THEN 'PROXIMAMENTE' ELSE 'CARTELERA' END
WHERE idPelicula <= 5;

-- Popularidad (1 a 5) que usa el generador: los "blockbusters" venden más
CREATE TABLE #Peli (idPelicula INT PRIMARY KEY, estreno DATE, pop FLOAT);
INSERT INTO #Peli
SELECT idPelicula, fechaEstreno,
       CASE titulo WHEN 'Planeta Rojo 2'      THEN 5 WHEN 'El Guardián del Sol' THEN 5
                   WHEN 'Velocidad Total'     THEN 4.5 WHEN 'El Rey de la Selva' THEN 4.5
                   WHEN 'Galaxia Cero'        THEN 4 WHEN 'Furia en el Pacífico' THEN 4
                   WHEN 'Código Inca'         THEN 3.5 WHEN 'Pequeños Héroes' THEN 3.5
                   WHEN 'Aventura en los Andes' THEN 3.5 WHEN 'La Casa del Cerro' THEN 3
                   WHEN 'Medianoche en Lima'  THEN 3 ELSE 2 END
FROM Pelicula WHERE fechaEstreno <= @hoy;

/* ---------- 8000 clientes ---------- */
CREATE TABLE #Nom (i INT IDENTITY(0,1), nombre VARCHAR(30), sexo CHAR(1));
INSERT INTO #Nom (nombre, sexo) VALUES
('José','M'),('Luis','M'),('Carlos','M'),('Jorge','M'),('Miguel','M'),('Juan','M'),('Diego','M'),('Renzo','M'),
('Álvaro','M'),('Bruno','M'),('Kevin','M'),('Sebastián','M'),('Mateo','M'),('Andrés','M'),('Ricardo','M'),
('María','F'),('Lucía','F'),('Andrea','F'),('Valeria','F'),('Camila','F'),('Rosa','F'),('Fiorella','F'),
('Daniela','F'),('Sofía','F'),('Ximena','F'),('Gabriela','F'),('Milagros','F'),('Paola','F'),('Carmen','F'),('Alejandra','F');
CREATE TABLE #Ape (i INT IDENTITY(0,1), apellido VARCHAR(30));
INSERT INTO #Ape (apellido) VALUES
('Quispe'),('Flores'),('Rodríguez'),('Sánchez'),('García'),('Rojas'),('Huamán'),('Mendoza'),('Torres'),('Vargas'),
('Ramos'),('Castillo'),('Chávez'),('Díaz'),('Paredes'),('Gutiérrez'),('Espinoza'),('Mamani'),('Salazar'),('Vega'),
('Cárdenas'),('Romero'),('Medina'),('Aguilar'),('Ríos'),('Silva'),('Campos'),('Herrera'),('Ccori'),('Palacios');

;WITH n AS (SELECT TOP (8000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n FROM sys.all_objects a CROSS JOIN sys.all_objects b)
INSERT INTO Cliente (dni, nombres, apellidos, correo, telefono, sexo, fechaNacimiento, fechaRegistro)
SELECT CAST(10000000 + n.n * 1013 AS VARCHAR(8)),
       nm.nombre,
       a1.apellido + ' ' + a2.apellido,
       LOWER(CAST(nm.nombre + '.' + LEFT(a1.apellido, CHARINDEX(' ', a1.apellido + ' ') - 1)
                  COLLATE SQL_Latin1_General_CP1253_CI_AI AS VARCHAR(60)))   -- quita tildes
            + CAST(n.n AS VARCHAR(5)) + '@mail.com',
       '9' + RIGHT('0000000' + CAST(ABS(CHECKSUM(NEWID())) % 100000000 AS VARCHAR(8)), 8),
       nm.sexo,
       DATEADD(DAY, -(16 * 365 + ABS(CHECKSUM(NEWID())) % (45 * 365)), @hoy),
       DATEADD(DAY, -(ABS(CHECKSUM(NEWID())) % 700), @hoy)
FROM n
JOIN #Nom nm ON nm.i = (n.n * 7)  % 30
JOIN #Ape a1 ON a1.i = (n.n * 11) % 30
JOIN #Ape a2 ON a2.i = (n.n * 17 + 3) % 30;

UPDATE Cliente SET sexo = CASE WHEN nombres IN ('Lucía','Andrea','Valeria') THEN 'F' ELSE 'M' END,
                   fechaNacimiento = DATEADD(YEAR, -(22 + idCliente * 4), @hoy),
                   fechaRegistro   = DATEADD(DAY, -400, @hoy)
WHERE idCliente <= 6;
GO

/* =====================================================================
   3. GENERADOR DE FUNCIONES Y VENTAS: 12 meses de historia + 10 días de
      cartelera futura (con la preventa hecha hasta este momento).
      8 sedes x 4 horarios por día. La demanda depende de la película,
      el día de la semana, el horario, la temporada y la sede.
   ===================================================================== */
DECLARE @hoy DATE = CAST(GETDATE() AS DATE);
DECLARE @ini DATE = DATEADD(MONTH, -12, @hoy);

CREATE TABLE #N (n INT PRIMARY KEY);
INSERT INTO #N SELECT TOP (400) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM sys.all_objects a CROSS JOIN sys.all_objects b;

CREATE TABLE #Hor (slot INT, hora TIME, factor FLOAT);
INSERT INTO #Hor VALUES (1,'14:30',0.55), (2,'17:00',0.85), (3,'19:30',1.30), (4,'22:00',0.90);

-- dow: 0 = lunes ... 6 = domingo (independiente del idioma del servidor)
CREATE TABLE #F (idFuncion INT, idSede INT, fecha DATE, slot INT, idPelicula INT, fechaHora DATETIME,
                 precio DECIMAL(8,2), capacidad INT, vendidas INT, grupo INT);
INSERT INTO #F (idSede, fecha, slot, idPelicula, fechaHora, precio, capacidad, vendidas, grupo)
SELECT s.idSede, d.fecha, h.slot, p.idPelicula,
       CAST(d.fecha AS DATETIME) + CAST(h.hora AS DATETIME),
       -- precio: Lima 24.90 / provincia 19.90; martes de promoción; fin de semana +3; matiné -4
       CASE WHEN d.dow = 1 THEN CASE WHEN s.region = 'Lima' THEN 14.90 ELSE 11.90 END
            ELSE CASE WHEN s.region = 'Lima' THEN 24.90 ELSE 19.90 END
                 + CASE WHEN d.dow >= 4 THEN 3 ELSE 0 END
                 - CASE WHEN h.slot = 1 THEN 4 ELSE 0 END END,
       80 + 20 * ((s.idSede + h.slot) % 3),
       0,
       CASE WHEN ABS(CHECKSUM(NEWID())) % 100 < 20 THEN 1
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 65 THEN 2
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 80 THEN 3 ELSE 4 END
FROM (SELECT DATEADD(DAY, n - 1, @ini) AS fecha, (DATEDIFF(DAY, '19000101', DATEADD(DAY, n - 1, @ini)) % 7) AS dow
      FROM #N WHERE DATEADD(DAY, n - 1, @ini) <= DATEADD(DAY, 9, @hoy)) d
CROSS JOIN Sede s
CROSS JOIN #Hor h
CROSS APPLY (SELECT TOP 1 pp.idPelicula
             FROM #Peli pp
             WHERE pp.estreno <= d.fecha AND DATEADD(DAY, 56, pp.estreno) > d.fecha
             ORDER BY pp.pop * (1 + ABS(CHECKSUM(NEWID(), s.idSede, h.slot)) % 100) DESC) p;

-- Butacas vendidas = capacidad x ocupación estimada
UPDATE f SET vendidas =
    CASE WHEN x.ocup > 0.98 THEN f.capacidad ELSE CAST(f.capacidad * x.ocup AS INT) END
FROM #F f
JOIN #Peli p ON p.idPelicula = f.idPelicula
JOIN Sede s  ON s.idSede = f.idSede
JOIN #Hor h  ON h.slot = f.slot
CROSS APPLY (SELECT DATEDIFF(DAY, '19000101', f.fecha) % 7 AS dow, MONTH(f.fecha) AS mes) c
CROSS APPLY (SELECT 0.20 * (0.55 + p.pop / 7.0) * h.factor
     * CHOOSE(c.dow + 1, 0.70, 1.45, 0.80, 0.90, 1.30, 1.60, 1.40)                     -- lun..dom
     * CHOOSE(c.mes, 1.25, 1.30, 0.80, 0.90, 0.85, 0.90, 1.35, 1.10, 0.85, 0.90, 0.95, 1.30) -- temporada
     * CHOOSE(s.idSede, 1.25, 1.10, 1.15, 0.95, 0.90, 0.75, 0.95, 0.80)                 -- sede
     * (1.15 - 0.09 * DATEDIFF(DAY, p.estreno, f.fecha) / 7.0)                         -- semanas en cartelera
     * (0.90 + 0.25 * DATEDIFF(DAY, DATEADD(MONTH, -12, CAST(GETDATE() AS DATE)), f.fecha) / 365.0) -- crecimiento
     * (0.60 + (ABS(CHECKSUM(NEWID())) % 80) / 100.0) AS ocup) x;
UPDATE #F SET vendidas = 1 WHERE vendidas < 1;
-- Funciones que aún no empiezan: solo se vendió la preventa (más cuanto más cerca está la función)
UPDATE #F SET vendidas = CAST(vendidas * CASE WHEN fechaHora < DATEADD(HOUR, 24, GETDATE()) THEN 0.55
                                              WHEN fechaHora < DATEADD(HOUR, 72, GETDATE()) THEN 0.25
                                              ELSE 0.08 END AS INT)
WHERE fechaHora > GETDATE();

DECLARE @baseF INT = (SELECT MAX(idFuncion) FROM Funcion);
UPDATE f SET idFuncion = @baseF + r.rn
FROM #F f JOIN (SELECT idSede, fecha, slot, ROW_NUMBER() OVER (ORDER BY fecha, slot, idSede) AS rn FROM #F) r
     ON r.idSede = f.idSede AND r.fecha = f.fecha AND r.slot = f.slot;

SET IDENTITY_INSERT Funcion ON;
INSERT INTO Funcion (idFuncion, idPelicula, sala, fechaHora, precio, butacasTotales, butacasDisponibles, idSede)
SELECT idFuncion, idPelicula, slot, fechaHora, precio, capacidad, capacidad - vendidas, idSede FROM #F;
SET IDENTITY_INSERT Funcion OFF;

/* ---------- Ventas: las butacas vendidas se agrupan en compras de 1 a 4 entradas ---------- */
CREATE TABLE #V (idVenta INT PRIMARY KEY, idFuncion INT, grupo INT, entradas INT, idSede INT, fechaHora DATETIME,
                 dias INT, r1 INT, r2 INT, r3 INT, r4 INT, r5 INT, canal VARCHAR(10), medio VARCHAR(10),
                 idCliente INT, fechaVenta DATETIME, estado VARCHAR(10));
DECLARE @baseV INT = 0;
INSERT INTO #V (idVenta, idFuncion, grupo, entradas, idSede, fechaHora, dias, r1, r2, r3, r4, r5)
SELECT @baseV + ROW_NUMBER() OVER (ORDER BY f.fechaHora, f.idFuncion, g.grupo),
       f.idFuncion, g.grupo, g.entradas, f.idSede, f.fechaHora,
       DATEDIFF(DAY, DATEADD(MONTH, -12, CAST(GETDATE() AS DATE)), f.fecha),
       ABS(CHECKSUM(NEWID())) % 100, ABS(CHECKSUM(NEWID())) % 100, ABS(CHECKSUM(NEWID())) % 10000,
       ABS(CHECKSUM(NEWID())) % 4320, ABS(CHECKSUM(NEWID())) % 100
FROM #F f
CROSS APPLY (SELECT (n.n - 1) / f.grupo AS grupo, COUNT(*) AS entradas
             FROM #N n WHERE n.n <= f.vendidas GROUP BY (n.n - 1) / f.grupo) g;

-- Canal: la APP crece durante el año (de 20% a 42%), la web se mantiene en 28%
UPDATE #V SET canal = CASE WHEN r1 < 20 + 22 * dias / 365.0 THEN 'APP'
                           WHEN r1 < 48 + 22 * dias / 365.0 THEN 'WEB' ELSE 'BOLETERIA' END;
UPDATE #V SET medio = CASE WHEN canal = 'BOLETERIA'
                           THEN CASE WHEN r2 < 40 THEN 'EFECTIVO' WHEN r2 < 72 THEN 'TARJETA' WHEN r2 < 92 THEN 'YAPE' ELSE 'PLIN' END
                           ELSE CASE WHEN r2 < 58 THEN 'TARJETA' WHEN r2 < 88 THEN 'YAPE' ELSE 'PLIN' END END,
              -- unos clientes compran más que otros (fidelizados); los 6 clientes demo van aparte
              idCliente  = 7 + CAST(((SELECT COUNT(*) FROM Cliente) - 6) * POWER(r3 / 10000.0, 1.2) AS INT),
              fechaVenta = CASE WHEN canal = 'BOLETERIA' THEN DATEADD(MINUTE, -(5 + r4 % 85), fechaHora)
                                ELSE DATEADD(MINUTE, -(30 + r4), fechaHora) END,
              estado     = CASE WHEN r5 < 2 THEN 'ANULADA' ELSE 'PAGADA' END;
-- Ninguna venta puede quedar en el futuro (preventa de las funciones de los próximos días)
UPDATE #V SET fechaVenta = DATEADD(MINUTE, -(1 + r4 % 2880), GETDATE()) WHERE fechaVenta > GETDATE();

-- Los 6 clientes de la demo (login con DNI) también tienen algunas compras
UPDATE #V SET idCliente = 1 + (idVenta / 1500) % 6 WHERE idVenta % 1500 = 0;

SET IDENTITY_INSERT Venta ON;
INSERT INTO Venta (idVenta, idCliente, idSede, fechaVenta, canal, medioPago, total, estado)
SELECT idVenta, idCliente, idSede, fechaVenta, canal, medio, 0, estado FROM #V;
SET IDENTITY_INSERT Venta OFF;

-- Entradas: butaca = fila A-J + número 1-12 según el orden de venta en la función
INSERT INTO Entrada (idCliente, idFuncion, butaca, fechaVenta, precioPagado, estado, idVenta)
SELECT v.idCliente, f.idFuncion,
       CHAR(65 + (n.n - 1) / 12) + CAST((n.n - 1) % 12 + 1 AS VARCHAR(2)),
       v.fechaVenta, f.precio,
       CASE WHEN v.estado = 'ANULADA' THEN 'ANULADA' ELSE 'ACTIVA' END,
       v.idVenta
FROM #F f
JOIN #N n ON n.n <= f.vendidas
JOIN #V v ON v.idFuncion = f.idFuncion AND v.grupo = (n.n - 1) / f.grupo;

-- Las anuladas devuelven su butaca
UPDATE fu SET butacasDisponibles = fu.butacasTotales - x.activas
FROM Funcion fu
JOIN (SELECT idFuncion, SUM(CASE WHEN estado = 'ACTIVA' THEN 1 ELSE 0 END) AS activas
      FROM Entrada GROUP BY idFuncion) x ON x.idFuncion = fu.idFuncion
WHERE fu.idFuncion > @baseF;

/* ---------- Dulcería: ~55% de las compras agrega productos ---------- */
CREATE TABLE #Prod (idProducto INT, peso INT);
INSERT INTO #Prod
SELECT idProducto, CASE categoria WHEN 'COMBO' THEN 9 WHEN 'CANCHITA' THEN 7 WHEN 'BEBIDA' THEN 6
                                  WHEN 'SNACK' THEN 3 ELSE 3 END
                 * CASE nombre WHEN 'Combo Clásico' THEN 2 WHEN 'Gaseosa Grande' THEN 2 ELSE 1 END
FROM Producto;

INSERT INTO DetalleVenta (idVenta, idProducto, cantidad, precioUnit)
SELECT v.idVenta, p.idProducto,
       CASE WHEN v.entradas >= 3 AND (v.r3 + l.n) % 3 = 0 THEN 2 ELSE 1 END,
       pr.precio
FROM #V v
JOIN #N l ON l.n <= 1 + (v.r3 % 7) / 3          -- 1, 2 o 3 productos
CROSS APPLY (SELECT TOP 1 x.idProducto FROM #Prod x
             ORDER BY x.peso * (1 + ABS(CHECKSUM(NEWID(), v.idVenta, l.n)) % 100) DESC) p
JOIN Producto pr ON pr.idProducto = p.idProducto
WHERE ABS(CHECKSUM(v.idVenta * 7919)) % 100 < 55 + CASE WHEN v.canal = 'BOLETERIA' THEN 10 ELSE 0 END - (v.r5 % 15);

-- Total de cada venta = entradas + dulcería
UPDATE v SET total = ISNULL(e.monto, 0) + ISNULL(d.monto, 0)
FROM Venta v
LEFT JOIN (SELECT idVenta, SUM(precioPagado) AS monto FROM Entrada GROUP BY idVenta) e ON e.idVenta = v.idVenta
LEFT JOIN (SELECT idVenta, SUM(subtotal) AS monto FROM DetalleVenta GROUP BY idVenta) d ON d.idVenta = v.idVenta;
GO

/* ---------- Las 3 entradas originales también se vuelven ventas de boletería ---------- */
DECLARE @ultima INT = (SELECT MAX(idVenta) FROM Venta);
INSERT INTO Venta (idCliente, idSede, fechaVenta, canal, medioPago, total)
SELECT idCliente, 1, fechaVenta, 'BOLETERIA', 'EFECTIVO', precioPagado FROM Entrada WHERE idVenta IS NULL ORDER BY idEntrada;
UPDATE e SET idVenta = b.idVenta
FROM Entrada e
JOIN (SELECT idEntrada, ROW_NUMBER() OVER (ORDER BY idEntrada) AS rn FROM Entrada WHERE idVenta IS NULL) a ON a.idEntrada = e.idEntrada
JOIN (SELECT idVenta,   ROW_NUMBER() OVER (ORDER BY idVenta)   AS rn FROM Venta   WHERE idVenta > @ultima) b ON b.rn = a.rn;
GO

/* =====================================================================
   4. METAS MENSUALES (entre -8% y +12% de lo real; el mes actual y el
      siguiente = promedio de los 3 últimos meses + 6%)
   ===================================================================== */
INSERT INTO MetaMensual (idSede, anio, mes, metaVentas)
SELECT idSede, YEAR(fechaVenta), MONTH(fechaVenta),
       ROUND(SUM(total) * (0.92 + (ABS(CHECKSUM(NEWID())) % 20) / 100.0), -2)
FROM Venta
WHERE estado = 'PAGADA' AND fechaVenta < DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)
GROUP BY idSede, YEAR(fechaVenta), MONTH(fechaVenta);

DECLARE @mesActual DATE = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
INSERT INTO MetaMensual (idSede, anio, mes, metaVentas)
SELECT s.idSede, YEAR(m.mes), MONTH(m.mes),
       ROUND(ISNULL((SELECT SUM(total) / 3 FROM Venta v WHERE v.idSede = s.idSede AND v.estado = 'PAGADA'
                     AND v.fechaVenta >= DATEADD(MONTH, -3, @mesActual) AND v.fechaVenta < @mesActual), 50000) * 1.06, -2)
FROM Sede s CROSS JOIN (VALUES (@mesActual), (DATEADD(MONTH, 1, @mesActual))) m(mes);
GO

/* =====================================================================
   5. CALENDARIO (desde el 1 de enero del año pasado hasta fin del próximo)
   ===================================================================== */
DECLARE @d DATE = DATEFROMPARTS(YEAR(GETDATE()) - 1, 1, 1);
DECLARE @fin DATE = DATEFROMPARTS(YEAR(GETDATE()) + 1, 12, 31);
;WITH n AS (SELECT TOP (DATEDIFF(DAY, @d, @fin) + 1) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS i
            FROM sys.all_objects a CROSS JOIN sys.all_objects b),
      f AS (SELECT DATEADD(DAY, i, @d) AS fecha FROM n)
INSERT INTO Calendario
SELECT fecha, YEAR(fecha), MONTH(fecha),
       CHOOSE(MONTH(fecha), 'Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'),
       CHOOSE(MONTH(fecha), 'Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic') + ' ' + RIGHT(CAST(YEAR(fecha) AS VARCHAR(4)), 2),
       YEAR(fecha) * 100 + MONTH(fecha),
       'T' + CAST(DATEPART(QUARTER, fecha) AS VARCHAR(1)),
       DATEDIFF(DAY, '19000101', fecha) % 7 + 1,
       CHOOSE(DATEDIFF(DAY, '19000101', fecha) % 7 + 1, 'Lunes','Martes','Miércoles','Jueves','Viernes','Sábado','Domingo'),
       CASE WHEN DATEDIFF(DAY, '19000101', fecha) % 7 >= 5 THEN 'Sí' ELSE 'No' END
FROM f;
GO

-- Índices para que Power BI (DirectQuery) responda rápido
CREATE INDEX IX_Entrada_BI ON Entrada(estado) INCLUDE (idFuncion, idCliente, idVenta, precioPagado, fechaVenta);
CREATE INDEX IX_Venta_BI   ON Venta(estado)   INCLUDE (idSede, idCliente, fechaVenta, canal, medioPago, total);
CREATE INDEX IX_Funcion_BI ON Funcion(idSede, fechaHora) INCLUDE (idPelicula, sala, butacasTotales, butacasDisponibles);
GO

/* =====================================================================
   6. VISTAS PARA POWER BI (modelo estrella)
   ===================================================================== */
CREATE VIEW vw_DimSede AS
SELECT idSede, nombre AS sede, ciudad, region, salas FROM Sede;
GO
CREATE VIEW vw_DimPelicula AS
SELECT idPelicula, titulo AS pelicula, genero, clasificacion, duracionMin, fechaEstreno, estado FROM Pelicula;
GO
CREATE VIEW vw_DimProducto AS
SELECT idProducto, nombre AS producto,
       CASE categoria WHEN 'COMBO' THEN 'Combos' WHEN 'CANCHITA' THEN 'Canchita' WHEN 'BEBIDA' THEN 'Bebidas'
                      WHEN 'SNACK' THEN 'Snacks' ELSE 'Dulces' END AS categoria,
       precio, costo FROM Producto;
GO
CREATE VIEW vw_DimCliente AS
SELECT idCliente, dni, nombres + ' ' + apellidos AS cliente,
       CASE sexo WHEN 'F' THEN 'Femenino' WHEN 'M' THEN 'Masculino' ELSE 'Sin dato' END AS sexo,
       CASE WHEN fechaNacimiento IS NULL THEN 'Sin dato'
            WHEN DATEDIFF(YEAR, fechaNacimiento, GETDATE()) < 25 THEN '18-24'
            WHEN DATEDIFF(YEAR, fechaNacimiento, GETDATE()) < 35 THEN '25-34'
            WHEN DATEDIFF(YEAR, fechaNacimiento, GETDATE()) < 45 THEN '35-44'
            WHEN DATEDIFF(YEAR, fechaNacimiento, GETDATE()) < 55 THEN '45-54'
            ELSE '55+' END AS rangoEdad
FROM Cliente;
GO
-- Una fila por compra (cabecera del carrito)
CREATE VIEW vw_FactVentas AS
SELECT v.idVenta, v.idCliente, v.idSede, v.fechaVenta AS fechaHoraVenta, CAST(v.fechaVenta AS DATE) AS fecha,
       DATEPART(HOUR, v.fechaVenta) AS horaVenta,
       CASE v.canal WHEN 'BOLETERIA' THEN 'Boletería' WHEN 'APP' THEN 'App' ELSE 'Web' END AS canal,
       CASE v.medioPago WHEN 'TARJETA' THEN 'Tarjeta' WHEN 'YAPE' THEN 'Yape' WHEN 'PLIN' THEN 'Plin' ELSE 'Efectivo' END AS medioPago,
       v.estado, v.total
FROM Venta v;
GO
-- Una fila por entrada vendida
CREATE VIEW vw_FactEntradas AS
SELECT e.idEntrada, e.idVenta, e.idCliente, f.idSede, f.idPelicula, e.idFuncion,
       CAST(e.fechaVenta AS DATE) AS fecha, CAST(f.fechaHora AS DATE) AS fechaFuncion,
       RIGHT('0' + CAST(DATEPART(HOUR, f.fechaHora) AS VARCHAR(2)), 2) + ':' +
       RIGHT('0' + CAST(DATEPART(MINUTE, f.fechaHora) AS VARCHAR(2)), 2) AS horario,
       e.butaca, e.precioPagado, e.estado
FROM Entrada e JOIN Funcion f ON f.idFuncion = e.idFuncion;
GO
-- Una fila por producto de dulcería vendido
CREATE VIEW vw_FactDulceria AS
SELECT d.idDetalle, d.idVenta, v.idCliente, v.idSede, d.idProducto, CAST(v.fechaVenta AS DATE) AS fecha,
       d.cantidad, d.precioUnit, d.subtotal, CAST(d.cantidad * p.costo AS DECIMAL(10,2)) AS costoTotal, v.estado
FROM DetalleVenta d JOIN Venta v ON v.idVenta = d.idVenta JOIN Producto p ON p.idProducto = d.idProducto;
GO
-- Una fila por función (para la ocupación de salas)
CREATE VIEW vw_FactFunciones AS
SELECT f.idFuncion, f.idSede, f.idPelicula, CAST(f.fechaHora AS DATE) AS fecha, f.sala,
       RIGHT('0' + CAST(DATEPART(HOUR, f.fechaHora) AS VARCHAR(2)), 2) + ':' +
       RIGHT('0' + CAST(DATEPART(MINUTE, f.fechaHora) AS VARCHAR(2)), 2) AS horario,
       f.butacasTotales AS capacidad, f.butacasTotales - f.butacasDisponibles AS vendidas
FROM Funcion f;
GO
CREATE VIEW vw_Metas AS
SELECT idSede, DATEFROMPARTS(anio, mes, 1) AS fecha, metaVentas FROM MetaMensual;
GO
SET NOEXEC OFF;
GO

/* ---------------- Verificación ---------------- */
SELECT (SELECT COUNT(*) FROM Cliente)      AS clientes,
       (SELECT COUNT(*) FROM Funcion)      AS funciones,
       (SELECT COUNT(*) FROM Venta)        AS ventas,
       (SELECT COUNT(*) FROM Entrada)      AS entradas,
       (SELECT COUNT(*) FROM DetalleVenta) AS lineasDulceria,
       (SELECT SUM(total) FROM Venta WHERE estado = 'PAGADA') AS ingresosTotales;

SELECT s.sede, FORMAT(SUM(v.total), 'N2') AS ingresos, COUNT(*) AS compras
FROM vw_FactVentas v JOIN vw_DimSede s ON s.idSede = v.idSede
WHERE v.estado = 'PAGADA' GROUP BY s.sede ORDER BY SUM(v.total) DESC;

/* =====================================================================
   PARTE 3 · EVALUACIÓN FINAL - SEGURIDAD DE APLICACIONES
   - Las contraseñas se guardan como hash SHA-256 (64 caracteres hex en minúscula)
   - Roles del personal: ADMIN (ve ventas y auditoría) y CAJERO
   - Tabla Auditoria para registrar eventos de seguridad
   Credenciales de prueba (solo se guarda su hash):
     admin  / Admin#2026   (ADMIN)
     cajero / Cajero#2026  (CAJERO)
     clientes: DNI (ej. 45678123) / Cliente#2026
   ===================================================================== */
USE BD_CineplanetFinal;
GO
SET NOCOUNT ON;

-- Usuario: clave con espacio para el hash y columna rol
ALTER TABLE Usuario ALTER COLUMN clave VARCHAR(64) NOT NULL;
ALTER TABLE Usuario ADD rol VARCHAR(10) NOT NULL CONSTRAINT DF_Usuario_Rol DEFAULT 'CAJERO'
                        CONSTRAINT CK_Usuario_Rol CHECK (rol IN ('ADMIN','CAJERO'));
GO
UPDATE Usuario SET rol = 'ADMIN' WHERE usuario = 'admin';
UPDATE Usuario SET clave = LOWER(CONVERT(VARCHAR(64),
       HASHBYTES('SHA2_256', CASE usuario WHEN 'admin' THEN 'Admin#2026' ELSE 'Cajero#2026' END), 2));

-- Cliente: se quita la clave por defecto en texto plano y se guarda el hash
DECLARE @df SYSNAME = (SELECT dc.name FROM sys.default_constraints dc
                       JOIN sys.columns c ON c.object_id = dc.parent_object_id AND c.column_id = dc.parent_column_id
                       WHERE dc.parent_object_id = OBJECT_ID('Cliente') AND c.name = 'clave');
IF @df IS NOT NULL EXEC('ALTER TABLE Cliente DROP CONSTRAINT ' + @df);
GO
ALTER TABLE Cliente ALTER COLUMN clave VARCHAR(64) NOT NULL;
GO
UPDATE Cliente SET clave = LOWER(CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', 'Cliente#2026'), 2));

-- Registro de eventos de seguridad
CREATE TABLE Auditoria (
    idAuditoria INT IDENTITY(1,1) PRIMARY KEY,
    fecha       DATETIME     NOT NULL DEFAULT GETDATE(),
    usuario     VARCHAR(30)  NOT NULL,            -- usuario del personal o DNI del cliente
    evento      VARCHAR(20)  NOT NULL CHECK (evento IN ('LOGIN_OK','LOGIN_FALLIDO','BLOQUEO','LOGOUT',
                                                       'COMPRA','ANULACION','ACCESO_DENEGADO','CSRF')),
    detalle     VARCHAR(200) NULL,
    ip          VARCHAR(45)  NULL
);
INSERT INTO Auditoria (usuario, evento, detalle, ip) VALUES
('admin', 'LOGIN_OK', 'Inicio de sesión del personal', '127.0.0.1');
GO

/* ---------------- Verificación de la parte 3 ---------------- */
SELECT usuario, rol, clave AS hashSHA256 FROM Usuario;
SELECT TOP 2 dni, nombres, clave AS hashSHA256 FROM Cliente ORDER BY idCliente;
