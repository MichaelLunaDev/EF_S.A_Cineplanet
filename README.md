# EF_S.A_Cineplanet

Evaluación Final – Seguridad de Aplicaciones (02414): tienda web segura de entradas y dulcería de Cineplanet en Java, aplicando los controles del OWASP Top 10.

## Tecnologías

- NetBeans 8.2 · GlassFish 4.1.1 · JDK 8 (Java EE 7 Web)
- SQL Server · driver `mssql-jdbc-13.4.0.jre8.jar`
- JSP + JSTL, Servlets y DAO con `PreparedStatement`

## Cómo ejecutarlo

1. En SQL Server Management Studio abre `bd/BD_CineplanetFinal.sql`, selecciona todo (Ctrl+A) y ejecútalo (F5). Tarda unos 40 segundos.
2. Verifica que el usuario `sa` tenga la clave `123` y que TCP/IP esté activo en el puerto 1433.
3. Abre en NetBeans la carpeta `Evaluacion_Final_Cineplanet`, haz **Clean and Build** y luego **Run**.
4. Entra a `http://localhost:8080/Evaluacion_Final_Cineplanet/`.

## Usuarios de prueba

| Rol | Usuario | Clave |
| --- | --- | --- |
| Administrador | `admin` | `Admin#2026` |
| Cajero | `cajero` | `Cajero#2026` |
| Cliente | DNI, por ejemplo `45678123` | `Cliente#2026` |

En la base de datos solo se guarda el hash SHA-256 de cada clave.

## Estructura

```
Evaluacion_Final_Cineplanet/
├── src/java/
│   ├── conexion/     Conexión a SQL Server
│   ├── modelo/       Clases de las tablas
│   ├── dao/          Acceso a datos (PreparedStatement)
│   ├── controlador/  Servlets
│   ├── filtro/       Filtros de sesión, roles y cabeceras
│   └── util/         Hash SHA-256 y token CSRF
└── web/
    ├── css/                   Estilos
    └── WEB-INF/vistas/        JSP (no accesibles por URL directa)
```

## Integrantes

LUNA URBANO, MICHAEL RODRIGO
ÑINGLE PEREZ, JOHANNA DANIELA
POMA RAMON, JEREMY MARTIN
RAMON QUISPE, KIMBERLY GIOVANNA
SALDAÑA PANANA, KEVIN ALONSO
