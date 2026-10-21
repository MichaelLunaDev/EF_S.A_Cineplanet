package controlador;

import dao.EntradaDAO;
import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import modelo.Cliente;

@WebServlet(name = "MisEntradasServlet", urlPatterns = {"/MisEntradasServlet"})
public class MisEntradasServlet extends HttpServlet {

    private final EntradaDAO entradaDAO = new EntradaDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Solo las entradas del cliente en sesion (WHERE e.idCliente = ?)
        Cliente cliente = (Cliente) request.getSession().getAttribute("cliente");
        try {
            request.setAttribute("entradas", entradaDAO.listarPorCliente(cliente.getIdCliente()));
        } catch (SQLException e) {
            throw new ServletException("No se pudieron consultar las entradas", e);
        }
        request.getRequestDispatcher("/WEB-INF/vistas/misEntradas.jsp").forward(request, response);
    }
}
