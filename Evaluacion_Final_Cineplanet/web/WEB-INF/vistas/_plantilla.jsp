<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Cineplanet - Clientes</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/cineplanet.css">
</head>
<body>
<c:set var="menu" value="clientes"/>
<%@include file="/WEB-INF/vistas/fragmentos/header-personal.jspf"%>

<main class="contenedor">

    <%-- 2. Encabezado: icono con color del modulo, titulo y descripcion --%>
    <div class="encabezado-pagina">
        <span class="icono-modulo c-naranja">
            <svg class="icono" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="9" cy="8" r="4"/><path d="M2 21c0-4 3-6 7-6s7 2 7 6"/></svg>
        </span>
        <div>
            <h1>Clientes</h1>
            <p>Registra y busca a los clientes que compran entradas.</p>
        </div>
    </div>
    <c:if test="${not empty error}">
        <div class="alerta alerta-error"><c:out value="${error}"/></div>
    </c:if>
    <c:if test="${not empty mensaje}">
        <div class="alerta alerta-exito"><c:out value="${mensaje}"/></div>
    </c:if>
    <section class="tarjeta">
        <h2>Nuevo cliente</h2>
        <p class="ayuda">El DNI debe tener 8 dígitos y no puede repetirse.</p>
        <form class="formulario" action="${pageContext.request.contextPath}/ClienteServlet" method="post">
            <input type="hidden" name="csrf" value="<c:out value='${sessionScope.csrf}'/>">
            <input type="hidden" name="accion" value="registrar">
            <div class="campo">
                <label for="dni">DNI</label>
                <input type="text" id="dni" name="dni" maxlength="8" placeholder="8 dígitos">
            </div>
            <div class="campo">
                <label for="nombres">Nombres</label>
                <input type="text" id="nombres" name="nombres" maxlength="60">
            </div>
            <div class="campo">
                <button type="submit" class="boton boton-primario">Registrar</button>
            </div>
        </form>
    </section>
    <section class="tarjeta">
        <div class="tabla-contenedor">
            <table class="tabla">
                <thead>
                    <tr><th>DNI</th><th>Cliente</th><th>Correo</th><th>Estado</th><th>Acciones</th></tr>
                </thead>
                <tbody>
                    <c:forEach var="x" items="${lista}">
                        <tr>
                            <td><c:out value="${x.dni}"/></td>
                            <td class="fuerte"><c:out value="${x.nombreCompleto}"/></td>
                            <td><c:out value="${x.correo}"/></td>
                            <td><span class="insignia i-activa">Activo</span></td>
                            <td class="acciones">
                                <form class="en-linea" action="${pageContext.request.contextPath}/ClienteServlet" method="post">
                                    <input type="hidden" name="csrf" value="<c:out value='${sessionScope.csrf}'/>">
                                    <input type="hidden" name="accion" value="eliminar">
                                    <input type="hidden" name="id" value="<c:out value='${x.idCliente}'/>">
                                    <button type="submit" class="boton boton-peligro boton-pequeno">Eliminar</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty lista}">
                        <tr><td colspan="5" class="vacio">No hay registros para mostrar.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </section>

</main>
</body>
</html>
