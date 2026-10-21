package controlador;

import dao.PeliculaDAO;
import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

// Catalogo de peliculas, solo lectura y solo ADMIN (lo controla SesionFilter).
@WebServlet(name = "PeliculaServlet", urlPatterns = {"/PeliculaServlet"})
public class PeliculaServlet extends HttpServlet {

    private final PeliculaDAO dao = new PeliculaDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String texto = request.getParameter("buscar");
        if (texto != null && texto.length() > 60) {
            texto = texto.substring(0, 60);
        }
        try {
            request.setAttribute("peliculas", dao.listar(texto));
        } catch (SQLException e) {
            throw new ServletException("No se pudieron consultar las peliculas", e);
        }
        request.getRequestDispatcher("/WEB-INF/vistas/peliculas.jsp").forward(request, response);
    }
}
