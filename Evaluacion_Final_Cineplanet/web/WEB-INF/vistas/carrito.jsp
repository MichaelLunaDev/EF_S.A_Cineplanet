
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Cineplanet - Mi carrito</title>
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/cineplanet.css">
</head>
<body>

<c:set var="menu" value="carrito"/>
<%@include file="/WEB-INF/vistas/fragmentos/header-cliente.jspf"%>

<main class="contenedor">

    <div class="encabezado-pagina">
        <div>
            <h1>Mi carrito</h1>
            <p>Revisa los productos que elegiste antes de continuar.</p>
        </div>
    </div>

    <c:if test="${not empty mensaje}">
        <div class="alerta alerta-exito">
            <c:out value="${mensaje}"/>
        </div>
    </c:if>

    <c:if test="${not empty error}">
        <div class="alerta alerta-error">
            <c:out value="${error}"/>
        </div>
    </c:if>

    <section class="tarjeta">
        <h2>Mis productos</h2>

        <c:choose>
            <c:when test="${empty productosCarrito}">
                <p class="vacio">
                    Aun no agregaste productos de dulceria.
                </p>
            </c:when>

            <c:otherwise>
                <c:set var="total" value="${0}"/>

                <div class="tabla-contenedor">
                    <table class="tabla">
                        <thead>
                            <tr>
                                <th>Producto</th>
                                <th>Categoria</th>
                                <th>Precio unitario</th>
                                <th>Cantidad</th>
                                <th>Subtotal</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${productosCarrito}" var="p">

                                <c:set var="cantidad"
                                       value="${carrito.productos[p.idProducto]}"/>

                                <c:set var="subtotal"
                                       value="${p.precio * cantidad}"/>

                                <c:set var="total"
                                       value="${total + subtotal}"/>

                                <tr>
                                    <td class="fuerte">
                                        <c:out value="${p.nombre}"/>
                                    </td>
                                    <td>
                                        <c:out value="${p.categoria}"/>
                                    </td>
                                    <td>
                                        S/
                                        <fmt:formatNumber
                                            value="${p.precio}"
                                            minFractionDigits="2"
                                            maxFractionDigits="2"/>
                                    </td>
                                    <td>
                                        <c:out value="${cantidad}"/>
                                    </td>
                                    <td class="precio">
                                        S/
                                        <fmt:formatNumber
                                            value="${subtotal}"
                                            minFractionDigits="2"
                                            maxFractionDigits="2"/>
                                    </td>
                                    <td>
                                        <form
                                            action="${pageContext.request.contextPath}/CarritoServlet"
                                            method="post">

                                            <input type="hidden"
                                                   name="csrf"
                                                   value="<c:out value='${sessionScope.csrf}'/>">

                                            <input type="hidden"
                                                   name="accion"
                                                   value="eliminarProducto">

                                            <input type="hidden"
                                                   name="idProducto"
                                                   value="${p.idProducto}">

                                            <button type="submit"
                                                    class="boton boton-secundario boton-pequeno">
                                                Quitar
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>

                <div class="total">
                    <span>Total de dulceria</span>
                    <span>
                        S/
                        <fmt:formatNumber
                            value="${total}"
                            minFractionDigits="2"
                            maxFractionDigits="2"/>
                    </span>
                </div>
            </c:otherwise>
        </c:choose>
    </section>

    <c:if test="${not empty carrito.butacas}">
        <section class="tarjeta">
            <h2>Butacas seleccionadas</h2>
            <p>Funcion: <c:out value="${carrito.idFuncion}"/></p>

            <c:forEach items="${carrito.butacas}" var="butaca">
                <span class="butaca-codigo">
                    <c:out value="${butaca}"/>
                </span>
            </c:forEach>
        </section>
    </c:if>

    <div class="fila-acciones">
        <a class="boton boton-secundario"
           href="${pageContext.request.contextPath}/TiendaServlet">
            Seguir comprando
        </a>

        <c:if test="${not empty carrito.butacas}">
            <a class="boton boton-primario"
               href="${pageContext.request.contextPath}/PagoServlet">
                Continuar al pago
            </a>
        </c:if>
    </div>

</main>
</body>
</html>
