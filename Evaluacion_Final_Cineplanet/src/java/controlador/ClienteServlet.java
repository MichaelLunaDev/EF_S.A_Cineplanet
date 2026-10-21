package controlador;

import dao.AuditoriaDAO;
import dao.ClienteDAO;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import modelo.Cliente;
import modelo.Usuario;
import util.Csrf;
import util.Seguridad;

@WebServlet(name = "ClienteServlet", urlPatterns = {"/ClienteServlet"})
public class ClienteServlet extends HttpServlet {

    private final ClienteDAO clienteDAO = new ClienteDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession sesion = request.getSession(false);
        if (sesion == null || sesion.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        String criterioBusqueda = request.getParameter("busqueda");
        List<Cliente> lista;

        if (criterioBusqueda != null && !criterioBusqueda.trim().isEmpty()) {
            lista = clienteDAO.buscar(criterioBusqueda.trim());
        } else {
            lista = clienteDAO.listar();
        }

        request.setAttribute("listaClientes", lista);
        request.getRequestDispatcher("/WEB-INF/vistas/clientes.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession sesion = request.getSession(false);
        if (sesion == null || sesion.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        if (!Csrf.esValido(request)) {
            Usuario u = (Usuario) sesion.getAttribute("usuario");
            AuditoriaDAO.registrar(u != null ? u.getUsuario() : "ANÓNIMO", "CSRF", "Intento de registro de cliente sin token CSRF válido", request.getRemoteAddr());
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Acción no autorizada (Token CSRF inválido)");
            return;
        }

        String dni = request.getParameter("dni");
        String nombres = request.getParameter("nombres");
        String apellidos = request.getParameter("apellidos");
        String correo = request.getParameter("correo");
        String telefono = request.getParameter("telefono");
        String clave = request.getParameter("clave");
        String ip = request.getRemoteAddr();

        if (dni == null || !dni.matches("^\\d{8}$")) {
            request.setAttribute("error", "El DNI debe tener exactamente 8 dígitos numéricos.");
            doGet(request, response);
            return;
        }

        String hashClave = Seguridad.sha256(clave);

        Cliente nuevoCliente = new Cliente();
        nuevoCliente.setDni(dni);
        nuevoCliente.setNombres(nombres);
        nuevoCliente.setApellidos(apellidos);
        nuevoCliente.setCorreo(correo);
        nuevoCliente.setTelefono(telefono);

        boolean registrado = clienteDAO.registrar(nuevoCliente, hashClave);

        if (registrado) {
            Usuario u = (Usuario) sesion.getAttribute("usuario");
            AuditoriaDAO.registrar(u.getUsuario(), "REGISTRO_CLIENTE", "Se registró exitosamente al cliente con DNI: " + dni, ip);
            request.setAttribute("mensaje", "Cliente registrado correctamente.");
        } else {
            request.setAttribute("error", "No se pudo registrar el cliente. Es posible que el DNI ya se encuentre registrado.");
        }

        doGet(request, response);
    }
}
