
package controlador;

import dao.AuditoriaDAO;
import dao.ButacasDAO;
import dao.ProductoDAO;
import dao.VentaDAO;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import modelo.Carrito;
import modelo.Cliente;
import modelo.Funcion;
import modelo.Producto;
import util.Csrf;

@WebServlet(name = "PagoServlet", urlPatterns = {"/PagoServlet"})
public class PagoServlet extends HttpServlet {

    private static final Logger LOG =
            Logger.getLogger(PagoServlet.class.getName());

    private static final Set<String> MEDIOS_PAGO =
            new HashSet<String>(
                Arrays.asList("TARJETA", "YAPE", "PLIN"));

    private final ButacasDAO butacasDAO = new ButacasDAO();
    private final ProductoDAO productoDAO = new ProductoDAO();
    private final VentaDAO ventaDAO = new VentaDAO();

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader("Cache-Control",
                "no-store, no-cache, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        HttpSession sesion = request.getSession(false);
        Cliente cliente = sesion == null
                ? null : (Cliente) sesion.getAttribute("cliente");

        if (cliente == null) {
            response.sendRedirect(
                    request.getContextPath() + "/LoginServlet");
            return;
        }

        String error = (String) sesion.getAttribute("errorPago");
        sesion.removeAttribute("errorPago");
        request.setAttribute("error", error);

        Integer idVentaConfirmada =
                (Integer) sesion.getAttribute("idVentaConfirmada");

        if (idVentaConfirmada != null) {
            sesion.removeAttribute("idVentaConfirmada");
            request.setAttribute("compraExitosa", Boolean.TRUE);
            request.setAttribute("idVenta", idVentaConfirmada);

            request.getRequestDispatcher(
                    "/WEB-INF/vistas/pago.jsp").forward(request, response);
            return;
        }

        Carrito carrito = (Carrito) sesion.getAttribute("carrito");

        if (carrito == null || carrito.getButacas().isEmpty()) {
            sesion.setAttribute("errorCarrito",
                    "Selecciona una funcion y sus butacas antes de pagar.");

            response.sendRedirect(
                    request.getContextPath() + "/CarritoServlet");
            return;
        }

        try {
            int idFuncion = carrito.getIdFuncion();

            Funcion funcion =
                    butacasDAO.buscarFuncionDisponible(idFuncion);

            if (funcion == null) {
                sesion.setAttribute("errorCarrito",
                        "La funcion ya no esta disponible. "
                        + "Vuelve a seleccionar una funcion.");

                response.sendRedirect(
                        request.getContextPath() + "/CarritoServlet");
                return;
            }

            List<String> butacas = new ArrayList<String>(
                    carrito.getButacas());

            if (butacas.size() > 10
                    || new HashSet<String>(butacas).size()
                       != butacas.size()) {

                volverAButacas(sesion, request, response, idFuncion,
                        "La seleccion de butacas no es valida.");
                return;
            }

            Set<String> ocupadas =
                    butacasDAO.listarButacasOcupadas(idFuncion);

            for (String codigo : butacas) {
                if (codigo == null
                        || !codigo.matches("^[A-J](?:[1-9]|1[0-2])$")) {

                    volverAButacas(sesion, request, response, idFuncion,
                            "Una de las butacas no es valida.");
                    return;
                }

                int fila = codigo.charAt(0) - 'A';
                int numero = Integer.parseInt(codigo.substring(1));
                int posicion = fila * 12 + numero;

                if (posicion > funcion.getButacasTotales()
                        || ocupadas.contains(codigo)) {

                    volverAButacas(sesion, request, response, idFuncion,
                            "Una de las butacas ya no esta disponible. "
                            + "Selecciona nuevamente.");
                    return;
                }
            }

            BigDecimal subtotalEntradas =
                    funcion.getPrecio().multiply(
                            BigDecimal.valueOf(butacas.size()));

            BigDecimal total = subtotalEntradas;

            List<Map<String, Object>> productosPago =
                    new ArrayList<Map<String, Object>>();

            Map<Integer, Integer> productos =
                    new LinkedHashMap<Integer, Integer>(
                            carrito.getProductos());

            for (Map.Entry<Integer, Integer> item
                    : productos.entrySet()) {

                Integer idProducto = item.getKey();
                Integer cantidad = item.getValue();

                if (idProducto == null || idProducto <= 0
                        || cantidad == null
                        || cantidad < 1 || cantidad > 10) {

                    sesion.setAttribute("errorCarrito",
                            "Hay un producto con una cantidad no valida.");

                    response.sendRedirect(
                            request.getContextPath() + "/CarritoServlet");
                    return;
                }

                Producto producto =
                        productoDAO.buscarActivoPorId(idProducto);

                if (producto == null) {
                    sesion.setAttribute("errorCarrito",
                            "Un producto ya no esta disponible. "
                            + "Revisa tu carrito.");

                    response.sendRedirect(
                            request.getContextPath() + "/CarritoServlet");
                    return;
                }

                BigDecimal subtotal = producto.getPrecio().multiply(
                        BigDecimal.valueOf(cantidad));

                Map<String, Object> linea =
                        new LinkedHashMap<String, Object>();

                linea.put("producto", producto);
                linea.put("cantidad", cantidad);
                linea.put("subtotal", subtotal);

                productosPago.add(linea);
                total = total.add(subtotal);
            }

            request.setAttribute("funcion", funcion);
            request.setAttribute("carrito", carrito);
            request.setAttribute("productosPago", productosPago);
            request.setAttribute("subtotalEntradas", subtotalEntradas);
            request.setAttribute(
                    "total", total.setScale(2, RoundingMode.HALF_UP));

            request.getRequestDispatcher(
                    "/WEB-INF/vistas/pago.jsp").forward(request, response);

        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "Error preparando el pago", e);

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession sesion = request.getSession(false);
        Cliente cliente = sesion == null
                ? null : (Cliente) sesion.getAttribute("cliente");

        if (cliente == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        if (!Csrf.esValido(request)) {
            AuditoriaDAO.registrar(
                    cliente.getDni(),
                    "CSRF",
                    "Token CSRF invalido en PagoServlet",
                    request.getRemoteAddr());

            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String medioPago = request.getParameter("medioPago");

        if (medioPago != null) {
            medioPago = medioPago.trim().toUpperCase(Locale.ROOT);
        }

        if (medioPago == null || !MEDIOS_PAGO.contains(medioPago)) {
            sesion.setAttribute("errorPago",
                    "Selecciona un medio de pago permitido.");

            response.sendRedirect(
                    request.getContextPath() + "/PagoServlet");
            return;
        }

        Carrito carrito = (Carrito) sesion.getAttribute("carrito");

        if (carrito == null || carrito.getButacas().isEmpty()) {
            sesion.setAttribute("errorCarrito",
                    "Tu carrito no tiene entradas seleccionadas.");

            response.sendRedirect(
                    request.getContextPath() + "/CarritoServlet");
            return;
        }

        try {
            int idVenta = ventaDAO.registrar(
                    cliente,
                    carrito,
                    medioPago,
                    request.getRemoteAddr());

            carrito.vaciar();
            sesion.removeAttribute("carrito");

            // Evita volver a enviar el formulario al actualizar la pagina.
            sesion.setAttribute("idVentaConfirmada", idVenta);

            response.sendRedirect(
                    request.getContextPath() + "/PagoServlet");

        } catch (SQLException e) {
            LOG.log(Level.WARNING, "No se pudo confirmar la compra", e);

            String detalle = e.getMessage() == null
                    ? "" : e.getMessage().toLowerCase(Locale.ROOT);

            if (detalle.contains("butaca")
                    || detalle.contains("funcion")) {

                sesion.setAttribute("errorButacas",
                        "La compra no pudo completarse porque la funcion "
                        + "o una butaca ya no esta disponible.");

                response.sendRedirect(
                        request.getContextPath()
                        + "/ButacasServlet?idFuncion="
                        + carrito.getIdFuncion());

            } else {
                sesion.setAttribute("errorPago",
                        "No se pudo completar la compra. "
                        + "Revisa tus datos e intenta nuevamente.");

                response.sendRedirect(
                        request.getContextPath() + "/PagoServlet");
            }
        }
    }

    private void volverAButacas(
            HttpSession sesion,
            HttpServletRequest request,
            HttpServletResponse response,
            int idFuncion,
            String mensaje) throws IOException {

        sesion.setAttribute("errorButacas", mensaje);

        response.sendRedirect(
                request.getContextPath()
                + "/ButacasServlet?idFuncion=" + idFuncion);
    }
}
