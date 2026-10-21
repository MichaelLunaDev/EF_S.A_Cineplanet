<%--
    Pagina de error propia: mensaje amigable, sin trazas de Java ni detalles internos.
    web.xml (Paso 6) debe enviar aqui los errores 403, 404, 500 y java.lang.Exception.
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="codigo" value="${requestScope['javax.servlet.error.status_code']}"/>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Cineplanet - Aviso</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/cineplanet.css">
</head>
<body>
<main class="error-pagina">
    <div class="error-tarjeta">
        <c:choose>
            <c:when test="${codigo == 403}">
                <div class="error-codigo">403</div>
                <h1>Acceso denegado</h1>
                <p>No tienes permiso para realizar esta acción o la solicitud no es válida.</p>
            </c:when>
            <c:when test="${codigo == 404}">
                <div class="error-codigo">404</div>
                <h1>Página no encontrada</h1>
                <p>La página que buscas no existe o fue movida.</p>
            </c:when>
            <c:otherwise>
                <div class="error-codigo">Ups</div>
                <h1>Algo salió mal</h1>
                <p>Ocurrió un problema al procesar tu solicitud. Inténtalo nuevamente en unos minutos.</p>
            </c:otherwise>
        </c:choose>
        <a class="boton boton-primario" href="${pageContext.request.contextPath}/LoginServlet">Volver al inicio</a>
    </div>
</main>
</body>
</html>
