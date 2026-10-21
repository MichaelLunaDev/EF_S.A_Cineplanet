<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Cineplanet - Entradas</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/cineplanet.css">
</head>
<body>
<c:set var="menu" value="entradas"/>
<%@include file="/WEB-INF/vistas/fragmentos/header-personal.jspf"%>

<main class="contenedor">

    <div class="encabezado-pagina">
        <span class="icono-modulo c-rosa">
            <svg class="icono" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 8a2 2 0 0 0 0 4v4h18v-4a2 2 0 0 1 0-4V4H3z"/><path d="M12 4v16"/></svg>
        </span>
        <div>
            <h1>Entradas</h1>
            <p>Consulta las entradas vendidas y anula las que correspondan.</p>
        </div>
    </div>

    <c:if test="${not empty error}">
        <div class="alerta alerta-error"><c:out value="${error}"/></div>
    </c:if>
    <c:if test="${not empty mensaje}">
        <div class="alerta alerta-exito"><c:out value="${mensaje}"/></div>
    </c:if>

    <section class="tarjeta">
        <form class="selector-sede" action="${pageContext.request.contextPath}/EntradaServlet" method="get">
            <div class="campo">
                <label for="dni">Buscar por DNI del cliente</label>
                <input type="text" id="dni" name="dni" maxlength="8" placeholder="8 dígitos"
                       value="<c:out value='${param.dni}'/>">
            </div>
            <button type="submit" class="boton boton-secundario">Buscar</button>
            <a class="boton boton-secundario" href="${pageContext.request.contextPath}/EntradaServlet">Ver últimas</a>
        </form>
    </section>

    <section class="tarjeta">
        <div class="tabla-contenedor">
            <table class="tabla">
                <thead>
                    <tr><th>N.°</th><th>Cliente</th><th>Película</th><th>Cine</th><th>Función</th><th>Butaca</th><th>Precio</th><th>Estado</th><th></th></tr>
                </thead>
                <tbody>
                    <c:forEach var="e" items="${entradas}">
                        <tr>
                            <td><c:out value="${e.idEntrada}"/></td>
                            <td class="fuerte"><c:out value="${e.nombreCliente}"/></td>
                            <td><c:out value="${e.tituloPelicula}"/></td>
                            <td><c:out value="${e.nombreSede}"/> · Sala <c:out value="${e.sala}"/></td>
                            <td><fmt:formatDate value="${e.fechaHoraFuncion}" pattern="dd/MM/yyyy HH:mm"/></td>
                            <td><span class="butaca-codigo"><c:out value="${e.butaca}"/></span></td>
                            <td class="precio">S/ <fmt:formatNumber value="${e.precioPagado}" minFractionDigits="2" maxFractionDigits="2"/></td>
                            <td><span class="insignia ${e.estado == 'ACTIVA' ? 'i-activa' : 'i-anulada'}"><c:out value="${e.estado}"/></span></td>
                            <td>
                                <c:if test="${e.estado == 'ACTIVA'}">
                                    <form class="en-linea" action="${pageContext.request.contextPath}/EntradaServlet" method="post">
                                        <input type="hidden" name="csrf" value="<c:out value='${sessionScope.csrf}'/>">
                                        <input type="hidden" name="idEntrada" value="<c:out value='${e.idEntrada}'/>">
                                        <button type="submit" class="boton boton-peligro boton-pequeno">Anular</button>
                                    </form>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty entradas}">
                        <tr><td colspan="9" class="vacio">No hay entradas para mostrar.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </section>

</main>
</body>
</html>
