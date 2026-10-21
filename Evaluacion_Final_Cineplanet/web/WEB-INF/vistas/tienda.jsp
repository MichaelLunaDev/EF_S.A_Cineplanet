
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Cineplanet - Dulceria</title>
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/cineplanet.css">
</head>
<body>

<c:set var="menu" value="tienda"/>
<%@include file="/WEB-INF/vistas/fragmentos/header-cliente.jspf"%>

<main class="contenedor">

    <div class="encabezado-pagina">
        <div>
            <h1>Dulceria Cineplanet</h1>
            <p>Elige tus productos favoritos para tu funcion.</p>
        </div>
    </div>

    <c:if test="${not empty error}">
        <div class="alerta alerta-error">
            <c:out value="${error}"/>
        </div>
    </c:if>

    <c:if test="${not empty mensaje}">
        <div class="alerta alerta-exito">
            <c:out value="${mensaje}"/>
        </div>
    </c:if>

    <section class="tarjeta">
        <h2>Productos disponibles</h2>
        <p class="ayuda">
            Precios consultados desde la base de datos.
        </p>

        <c:choose>
            <c:when test="${empty productos}">
                <p class="vacio">
                    No hay productos disponibles en este momento.
                </p>
            </c:when>

            <c:otherwise>
                <div class="tabla-contenedor">
                    <table>
                        <thead>
                            <tr>
                                <th>Producto</th>
                                <th>Categoria</th>
                                <th>Precio</th>
                                <th>Agregar al carrito</th>
                            </tr>
                        </thead>

                        <tbody>
                            <c:forEach items="${productos}" var="p">
                                <tr>
                                    <td>
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
                                        <form
                                            action="${pageContext.request.contextPath}/CarritoServlet"
                                            method="post">

                                            <input type="hidden"
                                                   name="csrf"
                                                   value="<c:out value='${sessionScope.csrf}'/>">

                                            <input type="hidden"
                                                   name="accion"
                                                   value="agregarProducto">

                                            <input type="hidden"
                                                   name="idProducto"
                                                   value="${p.idProducto}">

                                            <label>
                                                Cantidad
                                                <input type="number"
                                                       name="cantidad"
                                                       min="1"
                                                       max="10"
                                                       value="1"
                                                       required>
                                            </label>

                                            <button type="submit"
                                                    class="boton boton-primario">
                                                Agregar
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
    </section>

    <div style="margin-top: 20px;">
        <a class="boton boton-secundario"
           href="${pageContext.request.contextPath}/CarritoServlet">
            Ver carrito
        </a>
    </div>

</main>
</body>
</html>
