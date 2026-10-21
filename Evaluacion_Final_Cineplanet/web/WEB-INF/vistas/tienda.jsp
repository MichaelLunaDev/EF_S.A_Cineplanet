<%--
    Cartelera del cine elegido (proximos 7 dias) + dulceria.
    TiendaServlet debe enviar:
      sedes      List<Sede>      todas las sedes para el selector
      idSede     Integer         sede elegida
      funciones  List<Funcion>   funciones de la sede, ordenadas por fechaHora
                                 (con tituloPelicula, clasificacion y nombreSede llenos)
      productos  List<Producto>  productos con activo = 1
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Cineplanet - Cartelera</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/cineplanet.css">
</head>
<body>
<c:set var="menu" value="tienda"/>
<%@include file="/WEB-INF/vistas/fragmentos/header-cliente.jspf"%>
<fmt:setLocale value="es_PE"/>

<main class="contenedor">

    <section class="bienvenida">
        <div>
            <span class="etiqueta">Cartelera de los próximos 7 días</span>
            <h1>¡Hola, <c:out value="${sessionScope.cliente.nombres}"/>!</h1>
            <p>Elige tu cine y una función, marca tus butacas y agrega dulcería a tu carrito.</p>
        </div>
        <div class="mosaico">
            <span></span><span></span><span></span><span></span><span></span>
            <span></span><span></span><span></span><span></span><span></span>
        </div>
    </section>

    <c:if test="${not empty error}">
        <div class="alerta alerta-error"><c:out value="${error}"/></div>
    </c:if>
    <c:if test="${not empty mensaje}">
        <div class="alerta alerta-exito"><c:out value="${mensaje}"/></div>
    </c:if>

    <section class="tarjeta">
        <form class="selector-sede" action="${pageContext.request.contextPath}/TiendaServlet" method="get">
            <div class="campo">
                <label for="sede">Cine</label>
                <select id="sede" name="sede">
                    <c:forEach var="s" items="${sedes}">
                        <option value="<c:out value='${s.idSede}'/>" ${s.idSede == idSede ? 'selected' : ''}>
                            <c:out value="${s.nombre}"/> · <c:out value="${s.ciudad}"/>
                        </option>
                    </c:forEach>
                </select>
            </div>
            <button type="submit" class="boton boton-secundario">Ver cartelera</button>
        </form>

        <c:set var="diaAnterior" value=""/>
        <c:forEach var="f" items="${funciones}">
            <fmt:formatDate var="dia" value="${f.fechaHora}" pattern="EEEE d 'de' MMMM"/>
            <c:if test="${dia != diaAnterior}">
                <c:if test="${not empty diaAnterior}"></div></c:if>
                <h3 class="dia-titulo"><c:out value="${dia}"/></h3>
                <div class="funciones">
                <c:set var="diaAnterior" value="${dia}"/>
            </c:if>
            <article class="funcion">
                <div>
                    <c:choose>
                        <c:when test="${f.clasificacion == 'APT'}"><span class="insignia i-apt">APT</span></c:when>
                        <c:when test="${f.clasificacion == '+14'}"><span class="insignia i-14">+14</span></c:when>
                        <c:otherwise><span class="insignia i-18"><c:out value="${f.clasificacion}"/></span></c:otherwise>
                    </c:choose>
                </div>
                <span class="funcion-titulo"><c:out value="${f.tituloPelicula}"/></span>
                <span class="funcion-datos">
                    <fmt:formatDate value="${f.fechaHora}" pattern="HH:mm"/> · Sala <c:out value="${f.sala}"/>
                    · <c:out value="${f.butacasDisponibles}"/> butacas libres
                </span>
                <div class="funcion-pie">
                    <span class="precio">S/ <fmt:formatNumber value="${f.precio}" minFractionDigits="2" maxFractionDigits="2"/></span>
                    <c:choose>
                        <c:when test="${f.butacasDisponibles > 0}">
                            <a class="boton boton-primario boton-pequeno"
                               href="${pageContext.request.contextPath}/ButacasServlet?idFuncion=<c:out value='${f.idFuncion}'/>">Elegir butacas</a>
                        </c:when>
                        <c:otherwise><span class="insignia i-anulada">Agotado</span></c:otherwise>
                    </c:choose>
                </div>
            </article>
        </c:forEach>
        <c:if test="${not empty diaAnterior}"></div></c:if>
        <c:if test="${empty funciones}">
            <p class="vacio">No hay funciones programadas en este cine para los próximos 7 días.</p>
        </c:if>
    </section>

    <section class="tarjeta">
        <h2>Dulcería</h2>
        <p class="ayuda">Agrega combos y snacks a tu carrito. El precio final se calcula al pagar.</p>
        <div class="productos">
            <c:forEach var="p" items="${productos}">
                <div class="producto">
                    <span class="producto-categoria"><c:out value="${p.categoria}"/></span>
                    <span class="producto-nombre"><c:out value="${p.nombre}"/></span>
                    <span class="precio">S/ <fmt:formatNumber value="${p.precio}" minFractionDigits="2" maxFractionDigits="2"/></span>
                    <form action="${pageContext.request.contextPath}/CarritoServlet" method="post">
                        <input type="hidden" name="csrf" value="<c:out value='${sessionScope.csrf}'/>">
                        <input type="hidden" name="accion" value="agregarProducto">
                        <input type="hidden" name="idProducto" value="<c:out value='${p.idProducto}'/>">
                        <input type="number" name="cantidad" value="1" min="1" max="10" aria-label="Cantidad">
                        <button type="submit" class="boton boton-secundario boton-pequeno">Agregar</button>
                    </form>
                </div>
            </c:forEach>
        </div>
    </section>

</main>
</body>
</html>
