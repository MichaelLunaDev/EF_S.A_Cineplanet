
package controlador;

import dao.ReporteVentasDAO;
import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import modelo.Usuario;

@WebServlet(name = "VentaServlet", urlPatterns = {"/VentaServlet"})
public class VentaServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession sesion = request.getSession(false);

        if (sesion == null || sesion.getAttribute("usuario") == null) {
            response.sendRedirect(
                    request.getContextPath() + "/LoginServlet");
            return;
        }

        Usuario usuario = (Usuario) sesion.getAttribute("usuario");

        if (usuario.getRol() == null
                || !"ADMIN".equalsIgnoreCase(usuario.getRol())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        try {
            ReporteVentasDAO dao = new ReporteVentasDAO();

            request.setAttribute("ventas", dao.listarVentas());

            request.getRequestDispatcher(
                    "/WEB-INF/vistas/ventas.jsp")
                    .forward(request, response);

        } catch (SQLException e) {
            throw new ServletException(
                    "No se pudo generar el reporte de ventas.", e);
        }
    }
}
