<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Cineplanet - Comprobante</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/cineplanet.css">
</head>
<body>
<c:set var="menu" value="misentradas"/>
<%@include file="/WEB-INF/vistas/fragmentos/header-cliente.jspf"%>
<fmt:setLocale value="es_PE"/>

<main class="contenedor">

    <c:choose>
        <c:when test="${empty venta}">
            <section class="tarjeta">
                <div class="alerta alerta-error"><c:out value="${empty error ? 'Compra no encontrada' : error}"/></div>
                <div class="fila-acciones">
                    <a class="boton boton-primario" href="${pageContext.request.contextPath}/MisEntradasServlet">Ver mis entradas</a>
                </div>
            </section>
        </c:when>
        <c:otherwise>
            <c:if test="${not empty mensaje}">
                <div class="alerta alerta-exito"><c:out value="${mensaje}"/></div>
            </c:if>

            <section class="bienvenida">
                <div>
                    <span class="etiqueta">Comprobante de compra</span>
                    <h1>N.° <c:out value="${venta.idVenta}"/></h1>
                    <p>
                        <c:out value="${venta.nombreSede}"/> ·
                        <fmt:formatDate value="${venta.fechaVenta}" pattern="dd/MM/yyyy HH:mm"/> ·
                        Pago con <c:out value="${venta.medioPago}"/> ·
                        <c:out value="${venta.estado}"/>
                    </p>
                </div>
            </section>

            <section class="tarjeta">
                <h2>Entradas</h2>
                <div class="tabla-contenedor">
                    <table class="tabla">
                        <thead><tr><th>Película</th><th>Función</th><th>Sala</th><th>Butaca</th><th>Estado</th><th>Precio</th></tr></thead>
                        <tbody>
                            <c:forEach var="e" items="${venta.entradas}">
                                <tr>
                                    <td class="fuerte"><c:out value="${e.tituloPelicula}"/></td>
                                    <td><fmt:formatDate value="${e.fechaHoraFuncion}" pattern="dd/MM/yyyy HH:mm"/></td>
                                    <td><c:out value="${e.sala}"/></td>
                                    <td><span class="butaca-codigo"><c:out value="${e.butaca}"/></span></td>
                                    <td>
                                        <span class="insignia ${e.estado == 'ACTIVA' ? 'i-activa' : 'i-anulada'}"><c:out value="${e.estado}"/></span>
                                    </td>
                                    <td class="precio">S/ <fmt:formatNumber value="${e.precioPagado}" minFractionDigits="2" maxFractionDigits="2"/></td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty venta.entradas}">
                                <tr><td colspan="6" class="vacio">Esta compra no tiene entradas.</td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </section>

            <c:if test="${not empty venta.detalles}">
                <section class="tarjeta">
                    <h2>Dulcería</h2>
                    <div class="tabla-contenedor">
                        <table class="tabla">
                            <thead><tr><th>Producto</th><th>Cantidad</th><th>Precio</th><th>Subtotal</th></tr></thead>
                            <tbody>
                                <c:forEach var="d" items="${venta.detalles}">
                                    <tr>
                                        <td class="fuerte"><c:out value="${d.nombreProducto}"/></td>
                                        <td><c:out value="${d.cantidad}"/></td>
                                        <td>S/ <fmt:formatNumber value="${d.precioUnit}" minFractionDigits="2" maxFractionDigits="2"/></td>
                                        <td class="precio">S/ <fmt:formatNumber value="${d.subtotal}" minFractionDigits="2" maxFractionDigits="2"/></td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </section>
            </c:if>

            <section class="tarjeta">
                <div class="total">
                    <span>Total pagado</span>
                    <span>S/ <fmt:formatNumber value="${venta.total}" minFractionDigits="2" maxFractionDigits="2"/></span>
                </div>
                <div class="fila-acciones">
                    <a class="boton boton-secundario" href="${pageContext.request.contextPath}/MisEntradasServlet">Mis entradas</a>
                    <a class="boton boton-primario" href="${pageContext.request.contextPath}/TiendaServlet">Seguir comprando</a>
                </div>
            </section>
        </c:otherwise>
    </c:choose>

</main>
</body>
</html>
