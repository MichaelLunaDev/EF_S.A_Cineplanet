package util;

import dao.AuditoriaDAO;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class Csrf {

    private static final SecureRandom ALEATORIO = new SecureRandom();

    public static String generar(HttpSession sesion) {
        byte[] bytes = new byte[32];
        ALEATORIO.nextBytes(bytes);
        String token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        sesion.setAttribute("csrf", token);
        return token;
    }
    public static boolean esValido(HttpServletRequest request) {
        HttpSession sesion = request.getSession(false);
        if (sesion == null) {
            return false;
        }
        String esperado = (String) sesion.getAttribute("csrf");
        String recibido = request.getParameter("csrf");
        if (esperado == null || recibido == null) {
            return false;
        }
        return MessageDigest.isEqual(esperado.getBytes(StandardCharsets.UTF_8),
                                     recibido.getBytes(StandardCharsets.UTF_8));
    }

    // Uso al inicio de cada doPost que cambia datos (carrito, pago, anular):
    //     if (!Csrf.verificar(request, response)) { return; }
    // Si el token no coincide responde 403 y registra el evento CSRF en Auditoria.
    public static boolean verificar(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        if (esValido(request)) {
            return true;
        }
        AuditoriaDAO.registrar(quienEs(request), "CSRF",
                "Token CSRF invalido o ausente en " + request.getServletPath(), request.getRemoteAddr());
        response.sendError(HttpServletResponse.SC_FORBIDDEN, "Solicitud rechazada");
        return false;
    }

    private static String quienEs(HttpServletRequest request) {
        HttpSession sesion = request.getSession(false);
        if (sesion != null && sesion.getAttribute("usuario") instanceof modelo.Usuario) {
            return ((modelo.Usuario) sesion.getAttribute("usuario")).getUsuario();
        }
        if (sesion != null && sesion.getAttribute("cliente") instanceof modelo.Cliente) {
            return ((modelo.Cliente) sesion.getAttribute("cliente")).getDni();
        }
        return "anonimo";
    }
}
