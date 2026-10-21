
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reporte de ventas - Cineplanet</title>
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/cineplanet.css">
</head>
<body>
    <main class="contenedor">
        <section class="tarjeta">
            <h1>Reporte de ventas</h1>
            <p>Últimas ventas registradas en el sistema.</p>

            <c:choose>
                <c:when test="${empty ventas}">
                    <p>No hay ventas registradas.</p>
                </c:when>
                <c:otherwise>
                    <div class="tabla-contenedor">
                        <table>
                            <thead>
                                <tr>
                                    <th>N.º venta</th>
                                    <th>Fecha</th>
                                    <th>Sede</th>
                                    <th>Canal</th>
                                    <th>Medio de pago</th>
                                    <th>Total</th>
                                    <th>Estado</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="v" items="${ventas}">
                                    <tr>
                                        <td><c:out value="${v.idVenta}"/></td>
                                        <td>
                                            <fmt:formatDate
                                                value="${v.fechaVenta}"
                                                pattern="dd/MM/yyyy HH:mm"/>
                                        </td>
                                        <td><c:out value="${v.sede}"/></td>
                                        <td><c:out value="${v.canal}"/></td>
                                        <td><c:out value="${v.medioPago}"/></td>
                                        <td>
                                            S/
                                            <fmt:formatNumber
                                                value="${v.total}"
                                                minFractionDigits="2"
                                                maxFractionDigits="2"/>
                                        </td>
                                        <td><c:out value="${v.estado}"/></td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>

            <p>
                <a href="${pageContext.request.contextPath}/PanelServlet">
                    Volver al panel
                </a>
            </p>
        </section>
    </main>
</body>
</html>
