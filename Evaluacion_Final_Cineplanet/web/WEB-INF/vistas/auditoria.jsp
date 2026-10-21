<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Auditoría - Cineplanet</title>
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/cineplanet.css">
</head>
<body>
<c:set var="menu" value="auditoria"/>
<%@include file="/WEB-INF/vistas/fragmentos/header-personal.jspf"%>
<fmt:setLocale value="es_PE"/>
    <main class="contenedor">
        <section class="tarjeta">
            <h1>Auditoría del sistema</h1>
            <p>Últimos 100 eventos registrados.</p>

            <p>
                <a href="${pageContext.request.contextPath}/PanelServlet">
                    Volver al panel
                </a>
            </p>

            <div class="tabla-contenedor">
                <table class="tabla">
                    <thead>
                        <tr>
                            <th>Fecha</th>
                            <th>Usuario</th>
                            <th>Evento</th>
                            <th>Detalle</th>
                            <th>IP</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="a" items="${auditorias}">
                            <tr>
                                <td>
                                    <fmt:formatDate value="${a.fecha}" pattern="dd/MM/yyyy HH:mm:ss"/>
                                </td>
                                <td>
                                    <c:out value="${a.usuario}"/>
                                </td>
                                <td>
                                    <span class="insignia ${a.evento == 'LOGIN_OK' or a.evento == 'COMPRA' or a.evento == 'LOGOUT' ? 'i-activa' : 'i-anulada'}"><c:out value="${a.evento}"/></span>
                                </td>
                                <td>
                                    <c:out value="${a.detalle}"/>
                                </td>
                                <td>
                                    <c:out value="${a.ip}"/>
                                </td>
                            </tr>
                        </c:forEach>

                        <c:if test="${empty auditorias}">
                            <tr>
                                <td colspan="5">
                                    No hay eventos registrados.
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </section>
    </main>
</body>
</html>
