
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Error - Cineplanet</title>
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/cineplanet.css">
</head>
<body>
    <main class="contenedor">
        <section class="tarjeta">
            <h1>Ocurrió un problema</h1>

            <p>
                Lo sentimos, no fue posible completar tu solicitud.
            </p>

            <c:if test="${not empty requestScope['javax.servlet.error.status_code']}">
                <p>
                    Código de error:
                    <c:out value="${requestScope['javax.servlet.error.status_code']}"/>
                </p>
            </c:if>

            <a href="${pageContext.request.contextPath}/LoginServlet">
                Volver al inicio
            </a>
        </section>
    </main>
</body>
</html>
