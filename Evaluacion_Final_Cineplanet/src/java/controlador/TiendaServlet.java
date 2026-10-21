
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
    private final dao.CarteleraDAO carteleraDAO = new dao.CarteleraDAO();

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

        // Cine elegido: se valida que sea un numero; por defecto el primero
        int idSede = 1;
        String sede = request.getParameter("sede");
        if (sede != null && sede.matches("^\\d{1,3}$")) {
            idSede = Integer.parseInt(sede);
        }

        try {
            request.setAttribute("sedes", carteleraDAO.listarSedes());
            request.setAttribute("idSede", idSede);
            request.setAttribute("funciones", carteleraDAO.listarFunciones(idSede));
            request.setAttribute(
                    "productos", productoDAO.listarActivos());

        } catch (SQLException e) {
            LOG.log(Level.SEVERE,
                    "Error al consultar la cartelera o la dulceria", e);

            request.setAttribute("error",
                    "No se pudo cargar la cartelera. Intenta nuevamente.");
        }

        request.getRequestDispatcher(
                "/WEB-INF/vistas/tienda.jsp")
                .forward(request, response);
    }
}
