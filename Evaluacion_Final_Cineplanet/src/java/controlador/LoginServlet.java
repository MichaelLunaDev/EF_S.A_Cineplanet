package controlador;

import dao.AuditoriaDAO;
import dao.ClienteDAO;
import dao.UsuarioDAO;
import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
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

@WebServlet(name = "LoginServlet", urlPatterns = {"/LoginServlet"})
public class LoginServlet extends HttpServlet {

    private static class EstadoIntento {
        int fallos = 0;
        long tiempoBloqueoHasta = 0;
    }

    private static final Map<String, EstadoIntento> controlIntentos = new ConcurrentHashMap<>();
    private static final int MAX_INTENTOS = 3;
    private static final long TIEMPO_BLOQUEO_MS = 5 * 60 * 1000;

    private final UsuarioDAO usuarioDAO = new UsuarioDAO();
    private final ClienteDAO clienteDAO = new ClienteDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/vistas/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String identificador = request.getParameter("usuario"); 
        String clave = request.getParameter("clave");
        String ip = request.getRemoteAddr();

        if (identificador == null || identificador.trim().isEmpty() || clave == null || clave.trim().isEmpty()) {
            request.setAttribute("error", "Usuario o clave incorrectos");
            request.getRequestDispatcher("/WEB-INF/vistas/login.jsp").forward(request, response);
            return;
        }

        identificador = identificador.trim();
        long ahora = System.currentTimeMillis();

        controlIntentos.putIfAbsent(identificador, new EstadoIntento());
        EstadoIntento estado = controlIntentos.get(identificador);

        synchronized (estado) {
            if (estado.tiempoBloqueoHasta > ahora) {
                long minutosRestantes = ((estado.tiempoBloqueoHasta - ahora) / 1000 / 60) + 1;
                request.setAttribute("error", "Cuenta bloqueada temporalmente por intentos fallidos. Intente de nuevo en " + minutosRestantes + " minuto(s).");
                request.getRequestDispatcher("/WEB-INF/vistas/login.jsp").forward(request, response);
                return;
            } else if (estado.tiempoBloqueoHasta > 0 && estado.tiempoBloqueoHasta <= ahora) {
                estado.fallos = 0;
                estado.tiempoBloqueoHasta = 0;
            }
        }

        String hashClave = Seguridad.sha256(clave);

        boolean esDni = identificador.matches("^\\d{8}$");
        Usuario usuarioValido = null;
        Cliente clienteValido = null;

        if (esDni) {
            clienteValido = clienteDAO.validar(identificador, hashClave);
        } else {
            usuarioValido = usuarioDAO.validar(identificador, hashClave);
        }

        if (usuarioValido != null || clienteValido != null) {
            synchronized (estado) {
                estado.fallos = 0;
                estado.tiempoBloqueoHasta = 0;
            }

            HttpSession sesionVieja = request.getSession(false);
            if (sesionVieja != null) {
                sesionVieja.invalidate();
            }

            HttpSession nuevaSesion = request.getSession(true);

            Csrf.generar(nuevaSesion);

            if (usuarioValido != null) {
                nuevaSesion.setAttribute("usuario", usuarioValido);
                AuditoriaDAO.registrar(usuarioValido.getUsuario(), "LOGIN_OK", "Ingreso exitoso del personal (" + usuarioValido.getRol() + ")", ip);
                response.sendRedirect(request.getContextPath() + "/PanelServlet");
            } else {
                nuevaSesion.setAttribute("cliente", clienteValido);
                AuditoriaDAO.registrar(clienteValido.getDni(), "LOGIN_OK", "Ingreso exitoso del cliente", ip);
                response.sendRedirect(request.getContextPath() + "/TiendaServlet");
            }

        } else {
            boolean recienBloqueado = false;
            synchronized (estado) {
                estado.fallos++;
                if (estado.fallos >= MAX_INTENTOS) {
                    estado.tiempoBloqueoHasta = ahora + TIEMPO_BLOQUEO_MS;
                    recienBloqueado = true;
                }
            }

            if (recienBloqueado) {
                AuditoriaDAO.registrar(identificador, "BLOQUEO", "Bloqueo temporal de 5 minutos alcanzado tras " + MAX_INTENTOS + " intentos fallidos", ip);
                request.setAttribute("error", "Cuenta bloqueada temporalmente por 5 minutos tras superar los intentos permitidos.");
            } else {
                AuditoriaDAO.registrar(identificador, "LOGIN_FALLIDO", "Intento fallido de inicio de sesión", ip);
                request.setAttribute("error", "Usuario o clave incorrectos");
            }

            request.getRequestDispatcher("/WEB-INF/vistas/login.jsp").forward(request, response);
        }
    }
}