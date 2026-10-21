
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mis entradas - Cineplanet</title>
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/cineplanet.css">
</head>
<body>

    <main class="contenedor">
        <section class="tarjeta">
            <h1>Mis entradas</h1>

            <p>
                Consulta tus entradas y revisa su estado.
            </p>

            <c:if test="${not empty mensaje}">
                <p role="status">
                    <c:out value="${mensaje}"/>
                </p>
            </c:if>

            <c:choose>
                <c:when test="${empty entradas}">
                    <p>No tienes entradas registradas.</p>
                </c:when>

                <c:otherwise>
                    <div class="tabla-contenedor">
                        <table>
                            <thead>
                                <tr>
                                    <th>Película</th>
                                    <th>Sede</th>
                                    <th>Sala</th>
                                    <th>Fecha y hora</th>
                                    <th>Butaca</th>
                                    <th>Precio</th>
                                    <th>Estado</th>
                                    <th>Acción</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="e" items="${entradas}">
                                    <tr>
                                        <td>
                                            <c:out value="${e.tituloPelicula}"/>
                                        </td>
                                        <td>
                                            <c:out value="${e.nombreSede}"/>
                                        </td>
                                        <td>
                                            <c:out value="${e.sala}"/>
                                        </td>
                                        <td>
                                            <fmt:formatDate
                                                value="${e.fechaHoraFuncion}"
                                                pattern="dd/MM/yyyy HH:mm"/>
                                        </td>
                                        <td>
                                            <c:out value="${e.butaca}"/>
                                        </td>
                                        <td>
                                            S/
                                            <fmt:formatNumber
                                                value="${e.precioPagado}"
                                                minFractionDigits="2"
                                                maxFractionDigits="2"/>
                                        </td>
                                        <td>
                                            <c:out value="${e.estado}"/>
                                        </td>
                                        <td>
                                            <c:if test="${e.estado eq 'ACTIVA'}">
                                                <form method="post"
                                                      action="${pageContext.request.contextPath}/EntradaServlet">
                                                    <input type="hidden"
                                                           name="csrf"
                                                           value="<c:out value='${csrf}'/>">

                                                    <input type="hidden"
                                                           name="idEntrada"
                                                           value="<c:out value='${e.idEntrada}'/>">

                                                    <button type="submit">
                                                        Anular entrada
                                                    </button>
                                                </form>
                                            </c:if>

                                            <c:if test="${e.estado eq 'ANULADA'}">
                                                <span>Entrada anulada</span>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>

            <p>
                <a href="${pageContext.request.contextPath}/TiendaServlet">
                    Volver a la tienda
                </a>
            </p>
        </section>
    </main>

</body>
</html>
