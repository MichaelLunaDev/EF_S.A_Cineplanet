package util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;
import javax.servlet.http.HttpServletRequest;
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
}
