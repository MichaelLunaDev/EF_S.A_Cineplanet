package controlador;

import dao.AuditoriaDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import modelo.Cliente;
import modelo.Usuario;

@WebServlet(name = "LogoutServlet", urlPatterns = {"/LogoutServlet"})
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        cerrarSesion(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        cerrarSesion(request, response);
    }

    private void cerrarSesion(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        String ip = request.getRemoteAddr();

        if (session != null) {
            String identificador = "DESCONOCIDO";
            
            Usuario u = (Usuario) session.getAttribute("usuario");
            Cliente c = (Cliente) session.getAttribute("cliente");

            if (u != null) {
                identificador = u.getUsuario();
            } else if (c != null) {
                identificador = c.getDni();
            }

            AuditoriaDAO.registrar(identificador, "LOGOUT", "Cierre de sesión seguro", ip);
            
            session.invalidate();
        }

        response.sendRedirect(request.getContextPath() + "/LoginServlet");
    }
}