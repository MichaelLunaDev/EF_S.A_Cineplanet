
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Cineplanet - Seleccion de butacas</title>
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/cineplanet.css">
</head>
<body>

<c:set var="menu" value="tienda"/>
<%@include file="/WEB-INF/vistas/fragmentos/header-cliente.jspf"%>

<main class="contenedor">

    <div class="encabezado-pagina">
        <div>
            <h1>Selecciona tus butacas</h1>
            <p>Elige los asientos para tu proxima funcion.</p>
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
        <h2><c:out value="${funcion.tituloPelicula}"/></h2>

        <p>
            <strong>Sede:</strong>
            <c:out value="${funcion.nombreSede}"/>
        </p>

        <p>
            <strong>Sala:</strong>
            <c:out value="${funcion.sala}"/>
            &nbsp; | &nbsp;
            <strong>Clasificacion:</strong>
            <c:out value="${funcion.clasificacion}"/>
        </p>

        <p>
            <strong>Fecha y hora:</strong>
            <fmt:formatDate value="${funcion.fechaHora}"
                            pattern="dd/MM/yyyy HH:mm"/>
            &nbsp; | &nbsp;
            <strong>Precio por entrada:</strong>
            S/
            <fmt:formatNumber value="${funcion.precio}"
                              minFractionDigits="2"
                              maxFractionDigits="2"/>
        </p>
    </section>

    <section class="tarjeta">
        <h2>Mapa de butacas</h2>

        <div class="pantalla"></div>
        <div class="pantalla-texto">PANTALLA</div>

        <form action="${pageContext.request.contextPath}/ButacasServlet"
              method="post">

            <input type="hidden" name="csrf"
                   value="<c:out value='${sessionScope.csrf}'/>">

            <input type="hidden" name="idFuncion"
                   value="${funcion.idFuncion}">

            <div class="tabla-contenedor sala">
                <c:forEach items="${mapaFilas}" var="fila">
                    <div class="fila">
                        <span class="fila-letra">
                            <c:out value="${fila.letra}"/>
                        </span>

                        <c:forEach items="${fila.butacas}" var="b">

                            <c:if test="${b.numero == 7}">
                                <span class="pasillo"></span>
                            </c:if>

                            <c:choose>
                                <c:when test="${b.habilitada}">
                                    <label class="butaca">
                                        <input type="checkbox"
                                               name="butacas"
                                               value="<c:out value='${b.codigo}'/>"
                                               <c:if test="${b.seleccionada}">
                                                   checked="checked"
                                               </c:if>>
                                        <span>
                                            <c:out value="${b.numero}"/>
                                        </span>
                                    </label>
                                </c:when>

                                <c:otherwise>
                                    <label class="butaca">
                                        <input type="checkbox"
                                               disabled="disabled">
                                        <span title="Ocupada o fuera de capacidad">
                                            <c:out value="${b.numero}"/>
                                        </span>
                                    </label>
                                </c:otherwise>
                            </c:choose>

                        </c:forEach>
                    </div>
                </c:forEach>
            </div>

            <div class="leyenda">
                <span>
                    <i class="muestra muestra-libre"></i> Disponible
                </span>
                <span>
                    <i class="muestra muestra-elegida"></i> Seleccionada
                </span>
                <span>
                    <i class="muestra muestra-ocupada"></i> No disponible
                </span>
            </div>

            <div class="fila-acciones">
                <a class="boton boton-secundario"
                   href="${pageContext.request.contextPath}/TiendaServlet">
                    Volver
                </a>

                <button type="submit" class="boton boton-primario">
                    Confirmar butacas
                </button>
            </div>
        </form>
    </section>

</main>
</body>
</html>
