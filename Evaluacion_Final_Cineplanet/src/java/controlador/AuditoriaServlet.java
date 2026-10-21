
package controlador;

import dao.AuditoriaDAO;
import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "AuditoriaServlet",
            urlPatterns = {"/AuditoriaServlet"})
public class AuditoriaServlet extends HttpServlet {

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

        modelo.Usuario usuario =
                (modelo.Usuario) sesion.getAttribute("usuario");

        if (usuario.getRol() == null
                || !"ADMIN".equalsIgnoreCase(usuario.getRol())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        try {
            request.setAttribute("auditorias",
                    AuditoriaDAO.listarUltimos100());

            request.getRequestDispatcher(
                    "/WEB-INF/vistas/auditoria.jsp")
                    .forward(request, response);

        } catch (SQLException e) {
            throw new ServletException(
                    "No se pudo consultar la auditoría", e);
        }
    }
}
