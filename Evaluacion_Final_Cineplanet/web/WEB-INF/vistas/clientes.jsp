<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Cineplanet - Gestión de Clientes</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/cineplanet.css">
</head>
<body>

<c:set var="menu" value="clientes"/>
<%@include file="/WEB-INF/vistas/fragmentos/header-personal.jspf"%>

    <main class="contenedor">
        <h1>Gestión de Clientes</h1>
        <p>Registra nuevos clientes o busca los existentes en el sistema.</p>

        <c:if test="${not empty error}">
            <div class="alerta alerta-error"><c:out value="${error}"/></div>
        </c:if>
        <c:if test="${not empty mensaje}">
            <div class="alerta alerta-exito"><c:out value="${mensaje}"/></div>
        </c:if>

        <section class="tarjeta">
            <h2>Registrar Nuevo Cliente</h2>
            <form action="${pageContext.request.contextPath}/ClienteServlet" method="post" autocomplete="off">
         
                <input type="hidden" name="csrf" value="<c:out value='${sessionScope.csrf}'/>">
                
                <div class="campo">
                    <label for="dni">DNI (8 dígitos)</label>
                    <input type="text" id="dni" name="dni" maxlength="8" pattern="\d{8}" required placeholder="Ej: 45678123">
                </div>
                <div class="campo">
                    <label for="nombres">Nombres</label>
                    <input type="text" id="nombres" name="nombres" maxlength="50" required placeholder="Nombres del cliente">
                </div>
                <div class="campo">
                    <label for="apellidos">Apellidos</label>
                    <input type="text" id="apellidos" name="apellidos" maxlength="50" required placeholder="Apellidos del cliente">
                </div>
                <div class="campo">
                    <label for="correo">Correo Electrónico</label>
                    <input type="email" id="correo" name="correo" maxlength="80" required placeholder="correo@dominio.com">
                </div>
                <div class="campo">
                    <label for="telefono">Teléfono</label>
                    <input type="text" id="telefono" name="telefono" maxlength="15" placeholder="Teléfono o celular">
                </div>
                <div class="campo">
                    <label for="clave">Clave Inicial</label>
                    <input type="password" id="clave" name="clave" maxlength="50" required placeholder="Contraseña temporal">
                </div>
                <button type="submit" class="boton boton-primario">Guardar Cliente</button>
            </form>
        </section>

        <section class="tarjeta">
            <h2>Buscar Clientes</h2>
            <form action="${pageContext.request.contextPath}/ClienteServlet" method="get">
                <div class="campo-fila">
                    <input type="text" name="busqueda" value="<c:out value='${param.busqueda}'/>" placeholder="Buscar por DNI, nombre o apellido...">
                    <button type="submit" class="boton boton-secundario">Buscar</button>
                </div>
            </form>
        </section>

        <section class="tarjeta">
            <h2>Clientes Registrados</h2>
            <table class="tabla">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>DNI</th>
                        <th>Nombres</th>
                        <th>Apellidos</th>
                        <th>Correo</th>
                        <th>Teléfono</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty listaClientes}">
                            <c:forEach var="cli" items="${listaClientes}">
                                <tr>
                                    <td><c:out value="${cli.idCliente}"/></td>
                                    <td><c:out value="${cli.dni}"/></td>
                                    <td><c:out value="${cli.nombres}"/></td>
                                    <td><c:out value="${cli.apellidos}"/></td>
                                    <td><c:out value="${cli.correo}"/></td>
                                    <td><c:out value="${cli.telefono}"/></td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="6" class="vacio">No se encontraron clientes registrados.</td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </section>
    </main>

</body>
</html>