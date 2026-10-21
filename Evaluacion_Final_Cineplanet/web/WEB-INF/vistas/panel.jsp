<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Cineplanet - Panel</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/cineplanet.css">
</head>
<body>
<c:set var="menu" value="panel"/>
<%@include file="/WEB-INF/vistas/fragmentos/header-personal.jspf"%>

<main class="contenedor">

    <jsp:useBean id="hoy" class="java.util.Date"/>
    <fmt:setLocale value="es_PE"/>
    <section class="bienvenida">
        <div>
            <span class="etiqueta"><fmt:formatDate value="${hoy}" pattern="EEEE d 'de' MMMM 'de' yyyy"/></span>
            <h1>¡Hola, <c:out value="${sessionScope.usuario.nombre}"/>!</h1>
            <p>Bienvenido al sistema de Cineplanet. Elige un módulo para empezar a atender.</p>
        </div>
        <div class="mosaico">
            <span></span><span></span><span></span><span></span><span></span>
            <span></span><span></span><span></span><span></span><span></span>
            <span></span><span></span><span></span><span></span><span></span>
        </div>
    </section>

    <c:if test="${not empty mensaje}">
        <div class="alerta alerta-exito"><c:out value="${mensaje}"/></div>
    </c:if>

    <section class="modulos">
        <a class="modulo b-naranja" href="${pageContext.request.contextPath}/ClienteServlet">
            <span class="icono-modulo c-naranja"><svg class="icono" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="9" cy="8" r="4"/><path d="M2 21c0-4 3-6 7-6s7 2 7 6"/></svg></span>
            <h3>Clientes</h3>
            <p>Registrar y buscar clientes.</p>
            <span class="ir">Ir a clientes →</span>
        </a>
        <a class="modulo b-rosa" href="${pageContext.request.contextPath}/EntradaServlet">
            <span class="icono-modulo c-rosa"><svg class="icono" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 8a2 2 0 0 0 0 4v4h18v-4a2 2 0 0 1 0-4V4H3z"/><path d="M12 4v16"/></svg></span>
            <h3>Entradas</h3>
            <p>Consultar y anular entradas vendidas.</p>
            <span class="ir">Ir a entradas →</span>
        </a>
        <c:if test="${sessionScope.usuario.admin}">
            <a class="modulo b-verde" href="${pageContext.request.contextPath}/PeliculaServlet">
                <span class="icono-modulo c-verde"><svg class="icono" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M7 3v18M17 3v18M3 8h4M3 16h4M17 8h4M17 16h4"/></svg></span>
                <h3>Películas</h3>
                <p>Catálogo completo de películas. Solo administrador.</p>
                <span class="ir">Ir a películas →</span>
            </a>
            <a class="modulo b-azul" href="${pageContext.request.contextPath}/VentaServlet">
                <span class="icono-modulo c-azul"><svg class="icono" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 20V10M10 20V4M16 20v-8M22 20H2"/></svg></span>
                <h3>Ventas</h3>
                <p>Reporte de ventas por sede. Solo administrador.</p>
                <span class="ir">Ir a ventas →</span>
            </a>
            <a class="modulo b-amarillo" href="${pageContext.request.contextPath}/AuditoriaServlet">
                <span class="icono-modulo c-amarillo"><svg class="icono" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 3l8 3v6c0 5-3.5 8-8 9-4.5-1-8-4-8-9V6z"/><path d="M9 12l2 2 4-4"/></svg></span>
                <h3>Auditoría</h3>
                <p>Bitácora de eventos de seguridad. Solo administrador.</p>
                <span class="ir">Ir a auditoría →</span>
            </a>
        </c:if>
    </section>

</main>
</body>
</html>
