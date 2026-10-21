
package controlador;

import dao.AuditoriaDAO;
import dao.ProductoDAO;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
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
import modelo.Producto;
import util.Csrf;

@WebServlet(name = "CarritoServlet", urlPatterns = {"/CarritoServlet"})
public class CarritoServlet extends HttpServlet {

    private static final Logger LOG =
            Logger.getLogger(CarritoServlet.class.getName());

    private final ProductoDAO productoDAO = new ProductoDAO();

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession sesion = request.getSession(false);

        Cliente cliente = sesion == null
                ? null : (Cliente) sesion.getAttribute("cliente");

        if (cliente == null) {
            response.sendRedirect(
                    request.getContextPath() + "/LoginServlet");
            return;
        }

        response.setHeader("Cache-Control", "no-store");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        Carrito carrito = (Carrito) sesion.getAttribute("carrito");

        if (carrito == null) {
            carrito = new Carrito();
            sesion.setAttribute("carrito", carrito);
        }

        List<Producto> productosCarrito = new ArrayList<>();

        try {
            synchronized (carrito) {
                Iterator<Map.Entry<Integer, Integer>> iter =
                        carrito.getProductos().entrySet().iterator();

                while (iter.hasNext()) {
                    Map.Entry<Integer, Integer> item = iter.next();

                    Producto producto =
                            productoDAO.buscarActivoPorId(item.getKey());

                    if (producto == null) {
                        // Retirar productos que ya no esten activos.
                        iter.remove();
                    } else {
                        productosCarrito.add(producto);
                    }
                }
            }

            request.setAttribute("carrito", carrito);
            request.setAttribute("productosCarrito", productosCarrito);

            String mensaje = (String) sesion.getAttribute("mensajeCarrito");
            String error = (String) sesion.getAttribute("errorCarrito");

            sesion.removeAttribute("mensajeCarrito");
            sesion.removeAttribute("errorCarrito");

            request.setAttribute("mensaje", mensaje);
            request.setAttribute("error", error);

            request.getRequestDispatcher(
                    "/WEB-INF/vistas/carrito.jsp")
                    .forward(request, response);

        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "Error consultando productos del carrito", e);
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
                    "Token CSRF ausente o invalido en CarritoServlet",
                    request.getRemoteAddr());

            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String accion = request.getParameter("accion");

        Carrito carrito = (Carrito) sesion.getAttribute("carrito");

        if (carrito == null) {
            carrito = new Carrito();
            sesion.setAttribute("carrito", carrito);
        }

        try {
            if ("agregarProducto".equals(accion)) {

                int idProducto = Integer.parseInt(
                        request.getParameter("idProducto"));

                int cantidad = Integer.parseInt(
                        request.getParameter("cantidad"));

                if (idProducto <= 0 || cantidad < 1 || cantidad > 10) {
                    volverATiendaConError(request, response,
                            "Selecciona una cantidad entre 1 y 10.");
                    return;
                }

              
                Producto producto =
                        productoDAO.buscarActivoPorId(idProducto);

                if (producto == null) {
                    volverATiendaConError(request, response,
                            "El producto no existe o ya no esta disponible.");
                    return;
                }

                synchronized (carrito) {
                    Map<Integer, Integer> productos =
                            carrito.getProductos();

                    Integer anterior = productos.get(idProducto);
                    int cantidadActual = anterior == null ? 0 : anterior;
                    int nuevaCantidad = cantidadActual + cantidad;

                    if (nuevaCantidad > 10) {
                        volverATiendaConError(request, response,
                                "No puedes agregar mas de 10 unidades del mismo producto.");
                        return;
                    }

                    productos.put(idProducto, nuevaCantidad);
                }

                sesion.setAttribute("mensajeCarrito",
                        "Producto agregado correctamente.");

                response.sendRedirect(
                        request.getContextPath() + "/CarritoServlet");
                return;

            } else if ("eliminarProducto".equals(accion)) {

                int idProducto = Integer.parseInt(
                        request.getParameter("idProducto"));

                synchronized (carrito) {
                    carrito.getProductos().remove(idProducto);
                }

                sesion.setAttribute("mensajeCarrito",
                        "Producto retirado del carrito.");

                response.sendRedirect(
                        request.getContextPath() + "/CarritoServlet");
                return;

            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

        } catch (NumberFormatException e) {
            volverATiendaConError(request, response,
                    "Los datos enviados no son validos.");

        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "Error modificando el carrito", e);
            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private void volverATiendaConError(
            HttpServletRequest request,
            HttpServletResponse response,
            String mensaje)
            throws ServletException, IOException {

        try {
            request.setAttribute("error", mensaje);
            request.setAttribute(
                    "productos", productoDAO.listarActivos());

            request.getRequestDispatcher(
                    "/WEB-INF/vistas/tienda.jsp")
                    .forward(request, response);

        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "Error cargando la tienda", e);
            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
