
package controlador;

import dao.AuditoriaDAO;
import dao.ButacasDAO;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import modelo.Carrito;
import modelo.Cliente;
import modelo.Funcion;
import util.Csrf;

@WebServlet(name = "ButacasServlet", urlPatterns = {"/ButacasServlet"})
public class ButacasServlet extends HttpServlet {

    private static final Logger LOG =
            Logger.getLogger(ButacasServlet.class.getName());

    private final ButacasDAO butacasDAO = new ButacasDAO();

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader("Cache-Control", "no-store");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        HttpSession sesion = request.getSession(false);
        Cliente cliente = sesion == null
                ? null : (Cliente) sesion.getAttribute("cliente");

        if (cliente == null) {
            response.sendRedirect(
                    request.getContextPath() + "/LoginServlet");
            return;
        }

        int idFuncion;
        try {
            idFuncion = Integer.parseInt(
                    request.getParameter("idFuncion"));

            if (idFuncion <= 0) {
                throw new NumberFormatException();
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        try {
            Funcion funcion =
                    butacasDAO.buscarFuncionDisponible(idFuncion);

            if (funcion == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            Set<String> ocupadas =
                    butacasDAO.listarButacasOcupadas(idFuncion);

            Carrito carrito =
                    (Carrito) sesion.getAttribute("carrito");

            Set<String> seleccionadas = new HashSet<>();

            if (carrito != null
                    && carrito.getIdFuncion() == idFuncion) {
                seleccionadas.addAll(carrito.getButacas());
            }

            List<Map<String, Object>> mapaFilas =
                    construirMapa(funcion, ocupadas, seleccionadas);

            request.setAttribute("funcion", funcion);
            request.setAttribute("mapaFilas", mapaFilas);

            String error = (String) sesion.getAttribute("errorButacas");
            String mensaje = (String) sesion.getAttribute("mensajeButacas");

            sesion.removeAttribute("errorButacas");
            sesion.removeAttribute("mensajeButacas");

            request.setAttribute("error", error);
            request.setAttribute("mensaje", mensaje);

            request.getRequestDispatcher(
                    "/WEB-INF/vistas/butacas.jsp")
                    .forward(request, response);

        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "Error consultando las butacas", e);
            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession sesion = request.getSession(false);
        Cliente cliente = sesion == null
                ? null : (Cliente) sesion.getAttribute("cliente");

        if (cliente == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        if (!Csrf.esValido(request)) {
            AuditoriaDAO.registrar(
                    cliente.getDni(),
                    "CSRF",
                    "Token CSRF invalido al seleccionar butacas",
                    request.getRemoteAddr());

            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        int idFuncion;
        try {
            idFuncion = Integer.parseInt(
                    request.getParameter("idFuncion"));

            if (idFuncion <= 0) {
                throw new NumberFormatException();
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        try {
            Funcion funcion =
                    butacasDAO.buscarFuncionDisponible(idFuncion);

            if (funcion == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            Carrito carrito =
                    (Carrito) sesion.getAttribute("carrito");

            if (carrito == null) {
                carrito = new Carrito();
                sesion.setAttribute("carrito", carrito);
            }

            synchronized (carrito) {
                if (carrito.getCantidadEntradas() > 0
                        && carrito.getIdFuncion() != idFuncion) {
                    volverConError(sesion, response, idFuncion,
                            "Ya tienes butacas de otra funcion en tu carrito. "
                            + "Finaliza esa compra antes de cambiar de funcion.");
                    return;
                }
            }

            String[] valores = request.getParameterValues("butacas");

            Set<String> solicitadas = valores == null
                    ? new LinkedHashSet<String>()
                    : new LinkedHashSet<String>(Arrays.asList(valores));

            if (solicitadas.isEmpty()) {
                volverConError(sesion, response, idFuncion,
                        "Selecciona al menos una butaca.");
                return;
            }

            if (solicitadas.size() > 10) {
                volverConError(sesion, response, idFuncion,
                        "Puedes seleccionar como maximo 10 entradas.");
                return;
            }

            Set<String> ocupadas =
                    butacasDAO.listarButacasOcupadas(idFuncion);

            List<String> seleccionadas = new ArrayList<>();

            for (String codigo : solicitadas) {

                if (codigo == null
                        || !codigo.matches("^[A-J](?:[1-9]|1[0-2])$")) {
                    volverConError(sesion, response, idFuncion,
                            "Una de las butacas seleccionadas no es valida.");
                    return;
                }

                int fila = codigo.charAt(0) - 'A';
                int numero = Integer.parseInt(codigo.substring(1));
                int posicion = fila * 12 + numero;

                if (posicion > funcion.getButacasTotales()) {
                    volverConError(sesion, response, idFuncion,
                            "Una de las butacas supera la capacidad de la sala.");
                    return;
                }

                if (ocupadas.contains(codigo)) {
                    volverConError(sesion, response, idFuncion,
                            "Una de las butacas ya fue vendida. "
                            + "Actualiza el mapa y vuelve a elegir.");
                    return;
                }

                seleccionadas.add(codigo);
            }

            // Guardar solamente datos validados en el servidor.
            synchronized (carrito) {
                carrito.setIdFuncion(idFuncion);
                carrito.setButacas(seleccionadas);
            }

            sesion.setAttribute("mensajeCarrito",
                    "Butacas seleccionadas correctamente.");

            response.sendRedirect(
                    request.getContextPath() + "/CarritoServlet");

        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "Error guardando la seleccion", e);
            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private List<Map<String, Object>> construirMapa(
            Funcion funcion,
            Set<String> ocupadas,
            Set<String> seleccionadas) {

        List<Map<String, Object>> filas =
                new ArrayList<>();

        for (int i = 0; i < 10; i++) {
            char letra = (char) ('A' + i);

            Map<String, Object> fila = new LinkedHashMap<>();
            List<Map<String, Object>> asientos =
                    new ArrayList<>();

            fila.put("letra", String.valueOf(letra));

            for (int numero = 1; numero <= 12; numero++) {
                String codigo = letra + String.valueOf(numero);
                int posicion = i * 12 + numero;

                boolean dentroCapacidad =
                        posicion <= funcion.getButacasTotales();
                boolean ocupada = ocupadas.contains(codigo);

                Map<String, Object> b =
                        new LinkedHashMap<>();

                b.put("codigo", codigo);
                b.put("numero", numero);
                b.put("ocupada", ocupada);
                b.put("habilitada", dentroCapacidad && !ocupada);
                b.put("seleccionada",
                        dentroCapacidad
                        && !ocupada
                        && seleccionadas.contains(codigo));

                asientos.add(b);
            }

            fila.put("butacas", asientos);
            filas.add(fila);
        }

        return filas;
    }

    private void volverConError(
            HttpSession sesion,
            HttpServletResponse response,
            int idFuncion,
            String mensaje) throws IOException {

        sesion.setAttribute("errorButacas", mensaje);

        response.sendRedirect(
                response.encodeRedirectURL(
                        sesion.getServletContext().getContextPath()
                        + "/ButacasServlet?idFuncion=" + idFuncion));
    }
}
