<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Cineplanet - Iniciar sesión</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/cineplanet.css">
</head>
<body>
<main class="login">

    <section class="login-portada">
        <span class="marca">
            <span class="marca-icono"><span></span><span></span><span></span><span></span><span></span><span></span></span>
            cineplanet
        </span>

        <div>
            <h1>Tu función, tus butacas y tu <span>canchita</span> en un solo lugar.</h1>
            <p>Compra entradas y dulcería en línea. El personal del cine gestiona ventas, anulaciones y auditoría desde aquí.</p>
            <ul class="login-ventajas">
                <li><span class="punto c-naranja"></span>Elige tus butacas en el mapa de la sala</li>
                <li><span class="punto c-verde"></span>Agrega combos de dulcería a tu carrito</li>
                <li><span class="punto c-turquesa"></span>Paga con tarjeta, Yape o Plin</li>
            </ul>
        </div>

        <span class="login-pie">© Cineplanet · Acceso para clientes y personal</span>
    </section>

    <section class="login-formulario">
        <div class="login-tarjeta">
            <h2>Bienvenido</h2>
            <p class="ayuda">Clientes: usa tu DNI. Personal: usa tu usuario.</p>

            <c:if test="${not empty error}">
                <div class="alerta alerta-error"><c:out value="${error}"/></div>
            </c:if>
            <c:if test="${not empty mensaje}">
                <div class="alerta alerta-exito"><c:out value="${mensaje}"/></div>
            </c:if>

            <form action="${pageContext.request.contextPath}/LoginServlet" method="post" autocomplete="off">
                <div class="campo">
                    <label for="usuario">Usuario o DNI</label>
                    <input type="text" id="usuario" name="usuario" maxlength="30" required
                           value="<c:out value='${param.usuario}'/>" placeholder="Usuario o DNI">
                </div>
                <div class="campo">
                    <label for="clave">Clave</label>
                    <input type="password" id="clave" name="clave" maxlength="50" required
                           autocomplete="current-password" placeholder="*******">
                </div>
                <button type="submit" class="boton boton-primario boton-ancho">Ingresar</button>
            </form>
        </div>
    </section>

</main>
</body>
</html>
