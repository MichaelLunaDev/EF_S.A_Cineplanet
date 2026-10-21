package filtro;

import dao.AuditoriaDAO;
import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import modelo.Cliente;
import modelo.Usuario;

// Control de acceso por rol para todas las paginas privadas.
@WebFilter("/*")
public class SesionFilter implements Filter {

    private static final Set<String> CLIENTE = new HashSet<>(Arrays.asList(
            "/TiendaServlet", "/ButacasServlet", "/CarritoServlet",
            "/PagoServlet", "/ComprobanteServlet", "/MisEntradasServlet"));

    private static final Set<String> PERSONAL = new HashSet<>(Arrays.asList(
            "/PanelServlet", "/ClienteServlet", "/EntradaServlet"));

    private static final Set<String> SOLO_ADMIN = new HashSet<>(Arrays.asList(
            "/VentaServlet", "/AuditoriaServlet", "/PeliculaServlet"));

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        String ruta = request.getServletPath();

        boolean paraCliente = CLIENTE.contains(ruta);
        boolean paraPersonal = PERSONAL.contains(ruta);
        boolean paraAdmin = SOLO_ADMIN.contains(ruta);

        // Paginas publicas (login, logout, css, index): pasan sin control
        if (!paraCliente && !paraPersonal && !paraAdmin) {
            chain.doFilter(req, res);
            return;
        }

        // Paginas privadas: el boton Atras no debe mostrarlas despues del logout
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        HttpSession sesion = request.getSession(false);
        Usuario usuario = sesion == null ? null : (Usuario) sesion.getAttribute("usuario");
        Cliente cliente = sesion == null ? null : (Cliente) sesion.getAttribute("cliente");

        // Sin sesion: al login
        if (usuario == null && cliente == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        boolean permitido;
        if (paraCliente) {
            permitido = cliente != null;
        } else if (paraPersonal) {
            permitido = usuario != null;
        } else {
            permitido = usuario != null && usuario.isAdmin();
        }

        if (!permitido) {
            String quien = usuario != null ? usuario.getUsuario() : cliente.getDni();
            AuditoriaDAO.registrar(quien, "ACCESO_DENEGADO",
                    "Intento de abrir " + ruta + " sin el rol requerido", request.getRemoteAddr());
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        chain.doFilter(req, res);
    }

    @Override
    public void destroy() {
    }
}
