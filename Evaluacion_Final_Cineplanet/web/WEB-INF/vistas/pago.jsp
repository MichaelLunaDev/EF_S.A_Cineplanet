
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Cineplanet - Confirmar compra</title>
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/cineplanet.css">
</head>
<body>

<c:set var="menu" value="carrito"/>
<%@include file="/WEB-INF/vistas/fragmentos/header-cliente.jspf"%>

<main class="contenedor">

    <c:choose>
        <c:when test="${compraExitosa}">
            <section class="tarjeta">
                <h1>¡Compra registrada!</h1>

                <p>
                    Tu número de compra es:
                    <strong>
                        #<c:out value="${idVenta}"/>
                    </strong>
                </p>

                <p>
                    La compra se ha registrado en el sistema académico.
                    Este proyecto no realiza cargos financieros reales.
                </p>

                <a class="boton boton-primario"
                   href="${pageContext.request.contextPath}/TiendaServlet">
                    Volver a la tienda
                </a>
            </section>
        </c:when>

        <c:otherwise>
            <div class="encabezado-pagina">
                <div>
                    <h1>Confirmar compra</h1>
                    <p>Revisa el resumen y selecciona el medio de pago.</p>
                </div>
            </div>

            <c:if test="${not empty error}">
                <div class="alerta alerta-error">
                    <c:out value="${error}"/>
                </div>
            </c:if>

            <section class="tarjeta">
                <h2>Funcion y entradas</h2>

                <p>
                    <strong>Pelicula:</strong>
                    <c:out value="${funcion.tituloPelicula}"/>
                </p>

                <p>
                    <strong>Sede:</strong>
                    <c:out value="${funcion.nombreSede}"/>
                </p>

                <p>
                    <strong>Fecha:</strong>
                    <fmt:formatDate value="${funcion.fechaHora}"
                                    pattern="dd/MM/yyyy HH:mm"/>
                </p>

                <p><strong>Butacas:</strong>
                    <c:forEach items="${carrito.butacas}" var="butaca"
                               varStatus="estado">
                        <c:if test="${estado.index > 0}">, </c:if>
                        <c:out value="${butaca}"/>
                    </c:forEach>
                </p>

                <p>
                    <strong>Subtotal de entradas:</strong>
                    S/
                    <fmt:formatNumber value="${subtotalEntradas}"
                                      minFractionDigits="2"
                                      maxFractionDigits="2"/>
                </p>
            </section>

            <section class="tarjeta">
                <h2>Productos de dulceria</h2>

                <c:choose>
                    <c:when test="${empty productosPago}">
                        <p>No has agregado productos de dulceria.</p>
                    </c:when>

                    <c:otherwise>
                        <div class="tabla-contenedor">
                            <table>
                                <thead>
                                    <tr>
                                        <th>Producto</th>
                                        <th>Cantidad</th>
                                        <th>Subtotal</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach items="${productosPago}" var="item">
                                        <tr>
                                            <td>
                                                <c:out value="${item.producto.nombre}"/>
                                            </td>
                                            <td>
                                                <c:out value="${item.cantidad}"/>
                                            </td>
                                            <td>
                                                S/
                                                <fmt:formatNumber
                                                    value="${item.subtotal}"
                                                    minFractionDigits="2"
                                                    maxFractionDigits="2"/>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:otherwise>
                </c:choose>
            </section>

            <section class="tarjeta">
                <div class="total">
                    <span>Total de la compra</span>
                    <span>
                        S/
                        <fmt:formatNumber value="${total}"
                                          minFractionDigits="2"
                                          maxFractionDigits="2"/>
                    </span>
                </div>

                <h2>Medio de pago</h2>

                <form action="${pageContext.request.contextPath}/PagoServlet"
                      method="post">

                    <input type="hidden" name="csrf"
                           value="<c:out value='${sessionScope.csrf}'/>">

                    <div class="opciones-pago">
                        <label>
                            <input type="radio" name="medioPago"
                                   value="TARJETA" required>
                            Tarjeta
                        </label>

                        <label>
                            <input type="radio" name="medioPago"
                                   value="YAPE">
                            Yape
                        </label>

                        <label>
                            <input type="radio" name="medioPago"
                                   value="PLIN">
                            Plin
                        </label>
                    </div>

                    <p class="ayuda">
                        Simulación académica: no introduzcas datos reales
                        de tarjetas ni credenciales bancarias.
                    </p>

                    <div class="fila-acciones">
                        <a class="boton boton-secundario"
                           href="${pageContext.request.contextPath}/CarritoServlet">
                            Volver al carrito
                        </a>

                        <button type="submit"
                                class="boton boton-primario">
                            Confirmar compra
                        </button>
                    </div>
                </form>
            </section>
        </c:otherwise>
    </c:choose>

</main>
</body>
</html>
