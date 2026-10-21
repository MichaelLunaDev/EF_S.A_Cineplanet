
package controlador;

import dao.EntradaDAO;
import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import modelo.Cliente;
import util.Csrf;

@WebServlet(name = "EntradaServlet", urlPatterns = {"/EntradaServlet"})
public class EntradaServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession sesion = request.getSession(false);

        if (sesion == null || sesion.getAttribute("cliente") == null) {
            response.sendRedirect(
                    request.getContextPath() + "/LoginServlet");
            return;
        }

        Cliente cliente = (Cliente) sesion.getAttribute("cliente");

        try {
            EntradaDAO dao = new EntradaDAO();

            request.setAttribute(
                    "entradas",
                    dao.listarPorCliente(cliente.getIdCliente()));

            request.setAttribute("csrf", Csrf.generar(sesion));

            request.getRequestDispatcher(
                    "/WEB-INF/vistas/mis-entradas.jsp")
                    .forward(request, response);

        } catch (SQLException e) {
            throw new ServletException(
                    "No se pudieron consultar las entradas.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession sesion = request.getSession(false);

        if (sesion == null || sesion.getAttribute("cliente") == null) {
            response.sendRedirect(
                    request.getContextPath() + "/LoginServlet");
            return;
        }

        if (!Csrf.esValido(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        Cliente cliente = (Cliente) sesion.getAttribute("cliente");

        try {
            int idEntrada = Integer.parseInt(
                    request.getParameter("idEntrada"));

            String usuario = cliente.getCorreo();
            String ip = request.getRemoteAddr();

            EntradaDAO dao = new EntradaDAO();

            boolean anulada = dao.anular(
                    idEntrada,
                    cliente.getIdCliente(),
                    usuario,
                    ip);

            if (!anulada) {
                request.setAttribute(
                        "mensaje",
                        "La entrada no existe, ya fue anulada o no se puede anular.");
            } else {
                request.setAttribute(
                        "mensaje",
                        "La entrada se anuló correctamente.");
            }

            request.setAttribute(
                    "entradas",
                    dao.listarPorCliente(cliente.getIdCliente()));

            request.setAttribute("csrf", Csrf.generar(sesion));

            request.getRequestDispatcher(
                    "/WEB-INF/vistas/mis-entradas.jsp")
                    .forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        } catch (SQLException e) {
            throw new ServletException(
                    "No se pudo procesar la anulación.", e);
        }
    }
}
