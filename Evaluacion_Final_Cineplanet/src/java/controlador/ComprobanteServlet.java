package controlador;

import dao.VentaDAO;
import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import modelo.Cliente;
import modelo.Venta;

@WebServlet(name = "ComprobanteServlet", urlPatterns = {"/ComprobanteServlet"})
public class ComprobanteServlet extends HttpServlet {

    private final VentaDAO ventaDAO = new VentaDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // El cliente sale de la sesion (SesionFilter garantiza que existe), nunca de la URL
        Cliente cliente = (Cliente) request.getSession().getAttribute("cliente");

        Venta venta = null;
        String id = request.getParameter("id");
        if (id != null && id.matches("^\\d{1,9}$")) {
            try {
                venta = ventaDAO.buscarDelCliente(Integer.parseInt(id), cliente.getIdCliente());
            } catch (SQLException e) {
                throw new ServletException("No se pudo consultar la compra", e);
            }
        }

        if (venta == null) {
            // Mismo mensaje si no existe o si es de otro cliente: no se revela nada
            request.setAttribute("error", "Compra no encontrada");
        }
        request.setAttribute("venta", venta);
        request.getRequestDispatcher("/WEB-INF/vistas/comprobante.jsp").forward(request, response);
    }
}
