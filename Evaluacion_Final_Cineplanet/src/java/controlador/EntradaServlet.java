package controlador;

import dao.EntradaDAO;
import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import modelo.Usuario;
import util.Csrf;

// Modulo Entradas del personal: consulta y anulacion de entradas vendidas.
@WebServlet(name = "EntradaServlet", urlPatterns = {"/EntradaServlet"})
public class EntradaServlet extends HttpServlet {

    private final EntradaDAO dao = new EntradaDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        mostrar(request, response);
    }

    // Anular ya no es un enlace GET: es un formulario POST con token CSRF
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        if (!Csrf.verificar(request, response)) {
            return;
        }

        Usuario usuario = (Usuario) request.getSession().getAttribute("usuario");
        String id = request.getParameter("idEntrada");

        if (id == null || !id.matches("^\\d{1,9}$")) {
            request.setAttribute("error", "Entrada no válida.");
        } else {
            try {
                boolean anulada = dao.anular(Integer.parseInt(id), usuario.getUsuario(),
                        request.getRemoteAddr());
                if (anulada) {
                    request.setAttribute("mensaje", "La entrada " + id + " se anuló y la butaca quedó libre.");
                } else {
                    request.setAttribute("error", "La entrada no existe o ya estaba anulada.");
                }
            } catch (SQLException e) {
                throw new ServletException("No se pudo procesar la anulación.", e);
            }
        }
        mostrar(request, response);
    }

    private void mostrar(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String dni = request.getParameter("dni");
        if (dni != null && !dni.trim().isEmpty() && !dni.trim().matches("^\\d{8}$")) {
            request.setAttribute("error", "El DNI debe tener 8 dígitos.");
            dni = null;
        }
        try {
            request.setAttribute("entradas", dao.listarRecientes(dni == null ? null : dni.trim()));
        } catch (SQLException e) {
            throw new ServletException("No se pudieron consultar las entradas.", e);
        }
        request.getRequestDispatcher("/WEB-INF/vistas/entradas.jsp").forward(request, response);
    }
}
