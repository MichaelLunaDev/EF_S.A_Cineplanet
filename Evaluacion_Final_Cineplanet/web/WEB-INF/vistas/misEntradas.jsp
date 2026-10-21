<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Cineplanet - Mis entradas</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/cineplanet.css">
</head>
<body>
<c:set var="menu" value="misentradas"/>
<%@include file="/WEB-INF/vistas/fragmentos/header-cliente.jspf"%>
<fmt:setLocale value="es_PE"/>

<main class="contenedor">

    <section class="bienvenida">
        <div>
            <span class="etiqueta">Mis entradas</span>
            <h1>¡Hola, <c:out value="${sessionScope.cliente.nombres}"/>!</h1>
            <p>Aquí están tus entradas. Presenta el código de tu butaca en la puerta de la sala.</p>
        </div>
        <div class="mosaico">
            <span></span><span></span><span></span><span></span><span></span>
            <span></span><span></span><span></span><span></span><span></span>
        </div>
    </section>

    <c:set var="activas" value="0"/>
    <c:set var="totalPagado" value="0"/>
    <c:forEach var="e" items="${entradas}">
        <c:if test="${e.estado == 'ACTIVA'}">
            <c:set var="activas" value="${activas + 1}"/>
            <c:set var="totalPagado" value="${totalPagado + e.precioPagado}"/>
        </c:if>
    </c:forEach>

    <div class="indicadores">
        <div class="indicador">
            <span class="icono-modulo c-turquesa">
                <svg class="icono" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 6L9 17l-5-5"/></svg>
            </span>
            <div>
                <div class="indicador-titulo">Entradas activas</div>
                <div class="indicador-valor"><c:out value="${activas}"/></div>
            </div>
        </div>
        <div class="indicador destacado">
            <span class="icono-modulo c-naranja">
                <svg class="icono" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="6" width="20" height="12" rx="2"/><circle cx="12" cy="12" r="2"/></svg>
            </span>
            <div>
                <div class="indicador-titulo">Total pagado (entradas activas)</div>
                <div class="indicador-valor">S/ <fmt:formatNumber value="${totalPagado}" minFractionDigits="2" maxFractionDigits="2"/></div>
            </div>
        </div>
    </div>

    <div class="tickets">
        <c:forEach var="e" items="${entradas}">
            <article class="ticket ${e.estado == 'ACTIVA' ? '' : 'anulada'}">
                <div class="ticket-cuerpo">
                    <span class="insignia ${e.estado == 'ACTIVA' ? 'i-activa' : 'i-anulada'}"><c:out value="${e.estado}"/></span>
                    <div class="ticket-titulo"><c:out value="${e.tituloPelicula}"/></div>
                    <div class="ticket-datos">
                        <div><span>Fecha</span><fmt:formatDate value="${e.fechaHoraFuncion}" pattern="EEE d MMM"/></div>
                        <div><span>Hora</span><fmt:formatDate value="${e.fechaHoraFuncion}" pattern="HH:mm"/></div>
                        <div><span>Cine</span><c:out value="${e.nombreSede}"/></div>
                        <div><span>Sala</span><c:out value="${e.sala}"/></div>
                        <div><span>Precio</span>S/ <fmt:formatNumber value="${e.precioPagado}" minFractionDigits="2" maxFractionDigits="2"/></div>
                        <div><span>Compra</span>
                            <a href="${pageContext.request.contextPath}/ComprobanteServlet?id=<c:out value='${e.idVenta}'/>">N.° <c:out value="${e.idVenta}"/></a>
                        </div>
                    </div>
                </div>
                <div class="ticket-butaca">
                    <span>Butaca</span>
                    <strong><c:out value="${e.butaca}"/></strong>
                </div>
            </article>
        </c:forEach>
    </div>
    <c:if test="${empty entradas}">
        <section class="tarjeta">
            <p class="vacio">Todavía no tienes entradas.</p>
            <div class="fila-acciones">
                <a class="boton boton-primario" href="${pageContext.request.contextPath}/TiendaServlet">Ir a la cartelera</a>
            </div>
        </section>
    </c:if>

</main>
</body>
</html>
