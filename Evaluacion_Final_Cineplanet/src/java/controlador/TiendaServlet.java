
package controlador;

import dao.ProductoDAO;
import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import modelo.Cliente;

@WebServlet(name = "TiendaServlet", urlPatterns = {"/TiendaServlet"})
public class TiendaServlet extends HttpServlet {

    private static final Logger LOG =
            Logger.getLogger(TiendaServlet.class.getName());

    private final ProductoDAO productoDAO = new ProductoDAO();

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

        try {
            request.setAttribute(
                    "productos", productoDAO.listarActivos());

        } catch (SQLException e) {
            LOG.log(Level.SEVERE,
                    "Error al consultar el catalogo de productos", e);

            request.setAttribute("error",
                    "No se pudo cargar la dulceria. Intenta nuevamente.");
        }

        request.getRequestDispatcher(
                "/WEB-INF/vistas/tienda.jsp")
                .forward(request, response);
    }
}
