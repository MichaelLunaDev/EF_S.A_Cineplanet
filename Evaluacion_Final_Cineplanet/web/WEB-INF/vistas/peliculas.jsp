<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Cineplanet - Películas</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/cineplanet.css">
</head>
<body>
<c:set var="menu" value="peliculas"/>
<%@include file="/WEB-INF/vistas/fragmentos/header-personal.jspf"%>

<main class="contenedor">

    <div class="encabezado-pagina">
        <span class="icono-modulo c-verde">
            <svg class="icono" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M7 3v18M17 3v18M3 8h4M3 16h4M17 8h4M17 16h4"/></svg>
        </span>
        <div>
            <h1>Películas</h1>
            <p>Catálogo completo de películas en cartelera y próximos estrenos.</p>
        </div>
    </div>

    <section class="tarjeta">
        <form class="selector-sede" action="${pageContext.request.contextPath}/PeliculaServlet" method="get">
            <div class="campo">
                <label for="buscar">Buscar por título o género</label>
                <input type="text" id="buscar" name="buscar" maxlength="60" value="<c:out value='${param.buscar}'/>">
            </div>
            <button type="submit" class="boton boton-secundario">Buscar</button>
            <a class="boton boton-secundario" href="${pageContext.request.contextPath}/PeliculaServlet">Ver todas</a>
        </form>
    </section>

    <section class="tarjeta">
        <div class="tabla-contenedor">
            <table class="tabla">
                <thead>
                    <tr><th>Título</th><th>Género</th><th>Duración</th><th>Clasif.</th><th>Estreno</th><th>Estado</th></tr>
                </thead>
                <tbody>
                    <c:forEach var="p" items="${peliculas}">
                        <tr>
                            <td class="fuerte"><c:out value="${p.titulo}"/></td>
                            <td><c:out value="${p.genero}"/></td>
                            <td><c:out value="${p.duracionMin}"/> min</td>
                            <td>
                                <c:choose>
                                    <c:when test="${p.clasificacion == 'APT'}"><span class="insignia i-apt">APT</span></c:when>
                                    <c:when test="${p.clasificacion == '+14'}"><span class="insignia i-14">+14</span></c:when>
                                    <c:otherwise><span class="insignia i-18"><c:out value="${p.clasificacion}"/></span></c:otherwise>
                                </c:choose>
                            </td>
                            <td><fmt:formatDate value="${p.fechaEstreno}" pattern="dd/MM/yyyy"/></td>
                            <td>
                                <span class="insignia ${p.estado == 'CARTELERA' ? 'i-cartelera' : 'i-proximamente'}">
                                    <c:out value="${p.estado == 'CARTELERA' ? 'En cartelera' : 'Próximamente'}"/>
                                </span>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty peliculas}">
                        <tr><td colspan="6" class="vacio">No se encontraron películas.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </section>

</main>
</body>
</html>
