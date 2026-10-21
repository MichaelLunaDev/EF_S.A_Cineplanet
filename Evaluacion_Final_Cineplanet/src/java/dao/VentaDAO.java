
package dao;

import conexion.ConexionSQL;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import modelo.Carrito;
import modelo.Cliente;

public class VentaDAO {

    private static final Set<String> MEDIOS_PAGO =
            new HashSet<String>(
                Arrays.asList("TARJETA", "YAPE", "PLIN"));

    public int registrar(Cliente cliente, Carrito carrito,
            String medioPago, String ip) throws SQLException {

        if (cliente == null || carrito == null) {
            throw new SQLException(
                    "La sesion o el carrito no son validos.", "45000");
        }

        if (medioPago == null
                || !MEDIOS_PAGO.contains(medioPago)) {
            throw new SQLException(
                    "El medio de pago no esta permitido.", "45000");
        }

        int idFuncion;
        List<String> butacas;
        Map<Integer, Integer> productos;

        synchronized (carrito) {
            idFuncion = carrito.getIdFuncion();
            butacas = new ArrayList<String>(carrito.getButacas());
            productos = new LinkedHashMap<Integer, Integer>(
                    carrito.getProductos());
        }

        if (idFuncion <= 0 || butacas.isEmpty()) {
            throw new SQLException(
                    "Debes seleccionar una funcion y al menos una butaca.",
                    "45000");
        }

        if (butacas.size() > 10
                || new LinkedHashSet<String>(butacas).size()
                   != butacas.size()) {
            throw new SQLException(
                    "La cantidad de butacas no es valida.", "45000");
        }

        for (String butaca : butacas) {
            if (!esButacaValida(butaca)) {
                throw new SQLException(
                        "El formato de una butaca no es valido.", "45000");
            }
        }

        for (Map.Entry<Integer, Integer> item : productos.entrySet()) {
            if (item.getKey() == null
                    || item.getKey() <= 0
                    || item.getValue() == null
                    || item.getValue() < 1
                    || item.getValue() > 10) {
                throw new SQLException(
                        "Hay productos o cantidades no validas.", "45000");
            }
        }

        try (Connection cn = ConexionSQL.getConexion()) {
            cn.setAutoCommit(false);

            try {
                // Bloquear la funcion durante la transaccion.
                FuncionPago funcion = bloquearFuncion(cn, idFuncion);

                if (funcion == null) {
                    throw new SQLException(
                            "La funcion no existe o ya no esta disponible.",
                            "45000");
                }

                if (butacas.size() > funcion.butacasTotales
                        || butacas.size() > funcion.butacasDisponibles) {
                    throw new SQLException(
                            "No hay suficientes butacas disponibles.",
                            "45000");
                }

                // Comprobar nuevamente las butacas dentro de la transaccion.
                Set<String> ocupadas = consultarOcupadas(cn, idFuncion);

                for (String butaca : butacas) {
                    int fila = butaca.charAt(0) - 'A';
                    int numero = Integer.parseInt(butaca.substring(1));
                    int posicion = fila * 12 + numero;

                    if (posicion > funcion.butacasTotales) {
                        throw new SQLException(
                                "La butaca supera la capacidad de la sala.",
                                "45000");
                    }

                    if (ocupadas.contains(butaca)) {
                        throw new SQLException(
                                "BUTACA_OCUPADA: " + butaca, "45000");
                    }
                }

                // Calcular el total usando precios obtenidos de la BD.
                BigDecimal total = funcion.precio.multiply(
                        BigDecimal.valueOf(butacas.size()));

                Map<Integer, BigDecimal> preciosProductos =
                        new LinkedHashMap<Integer, BigDecimal>();

                for (Map.Entry<Integer, Integer> item
                        : productos.entrySet()) {

                    BigDecimal precio = consultarPrecioProducto(
                            cn, item.getKey());

                    if (precio == null) {
                        throw new SQLException(
                                "Un producto ya no esta disponible: "
                                + item.getKey(), "45000");
                    }

                    preciosProductos.put(item.getKey(), precio);

                    BigDecimal subtotal = precio.multiply(
                            BigDecimal.valueOf(item.getValue()));

                    total = total.add(subtotal);
                }

                total = total.setScale(
                        2, java.math.RoundingMode.HALF_UP);

                // 1. Crear la venta.
                int idVenta = insertarVenta(
                        cn, cliente.getIdCliente(), funcion.idSede,
                        medioPago, total);

                // 2. Registrar las entradas.
                insertarEntradas(
                        cn, cliente.getIdCliente(), idFuncion,
                        idVenta, butacas, funcion.precio);

                // 3. Descontar las butacas disponibles.
                String sqlActualizar =
                        "UPDATE Funcion "
                      + "SET butacasDisponibles = butacasDisponibles - ? "
                      + "WHERE idFuncion = ? AND butacasDisponibles >= ?";

                try (PreparedStatement ps =
                        cn.prepareStatement(sqlActualizar)) {

                    ps.setInt(1, butacas.size());
                    ps.setInt(2, idFuncion);
                    ps.setInt(3, butacas.size());

                    if (ps.executeUpdate() != 1) {
                        throw new SQLException(
                                "No fue posible reservar las butacas.",
                                "45000");
                    }
                }

                // 4. Registrar los productos de la venta.
                String sqlDetalle =
                        "INSERT INTO DetalleVenta "
                      + "(idVenta, idProducto, cantidad, precioUnit) "
                      + "VALUES (?, ?, ?, ?)";

                try (PreparedStatement ps =
                        cn.prepareStatement(sqlDetalle)) {

                    for (Map.Entry<Integer, Integer> item
                            : productos.entrySet()) {

                        ps.setInt(1, idVenta);
                        ps.setInt(2, item.getKey());
                        ps.setInt(3, item.getValue());
                        ps.setBigDecimal(
                                4, preciosProductos.get(item.getKey()));
                        ps.addBatch();
                    }

                    if (!productos.isEmpty()) {
                        ps.executeBatch();
                    }
                }

                // Confirmar toda la compra en una sola transaccion.
                cn.commit();

                // Auditoria con la IP real recibida del servlet.
                AuditoriaDAO.registrar(
                        cliente.getDni(),
                        "COMPRA",
                        "Venta #" + idVenta
                        + "; entradas=" + butacas.size()
                        + "; productos=" + productos.size()
                        + "; total=S/ " + total,
                        ip);

                return idVenta;

            } catch (SQLException e) {
                try {
                    cn.rollback();
                } catch (SQLException rollbackError) {
                    e.addSuppressed(rollbackError);
                }

                throw e;

            } catch (RuntimeException e) {
                try {
                    cn.rollback();
                } catch (SQLException rollbackError) {
                    e.addSuppressed(rollbackError);
                }

                throw e;
            }
        }
    }

    private FuncionPago bloquearFuncion(
            Connection cn, int idFuncion) throws SQLException {

        String sql =
                "SELECT f.idSede, f.precio, f.butacasTotales, "
              + "f.butacasDisponibles "
              + "FROM Funcion f WITH (UPDLOCK, HOLDLOCK) "
              + "INNER JOIN Pelicula p ON p.idPelicula = f.idPelicula "
              + "WHERE f.idFuncion = ? "
              + "AND f.fechaHora >= CONVERT(date, GETDATE()) "
              + "AND f.fechaHora < DATEADD(day, 7, CONVERT(date, GETDATE())) "
              + "AND p.estado = 'CARTELERA'";

        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idFuncion);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    FuncionPago f = new FuncionPago();
                    f.idSede = rs.getInt("idSede");
                    f.precio = rs.getBigDecimal("precio");
                    f.butacasTotales = rs.getInt("butacasTotales");
                    f.butacasDisponibles =
                            rs.getInt("butacasDisponibles");

                    return f;
                }
            }
        }

        return null;
    }

    private Set<String> consultarOcupadas(
            Connection cn, int idFuncion) throws SQLException {

        Set<String> ocupadas = new HashSet<String>();

        String sql =
                "SELECT butaca FROM Entrada "
              + "WHERE idFuncion = ? AND estado = 'ACTIVA'";

        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idFuncion);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ocupadas.add(rs.getString("butaca"));
                }
            }
        }

        return ocupadas;
    }

    private BigDecimal consultarPrecioProducto(
            Connection cn, int idProducto) throws SQLException {

        String sql =
                "SELECT precio FROM Producto "
              + "WHERE idProducto = ? AND activo = 1";

        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idProducto);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getBigDecimal("precio");
                }
            }
        }

        return null;
    }

    private int insertarVenta(
            Connection cn, int idCliente, int idSede,
            String medioPago, BigDecimal total) throws SQLException {

        String sql =
                "INSERT INTO Venta "
              + "(idCliente, idSede, canal, medioPago, total, estado) "
              + "OUTPUT INSERTED.idVenta "
              + "VALUES (?, ?, 'WEB', ?, ?, 'PAGADA')";

        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idCliente);
            ps.setInt(2, idSede);
            ps.setString(3, medioPago);
            ps.setBigDecimal(4, total);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        throw new SQLException("No se pudo registrar la venta.");
    }

    private void insertarEntradas(
            Connection cn, int idCliente, int idFuncion,
            int idVenta, List<String> butacas,
            BigDecimal precio) throws SQLException {

        String sql =
                "INSERT INTO Entrada "
              + "(idCliente, idFuncion, idVenta, butaca, "
              + "precioPagado, estado) "
              + "VALUES (?, ?, ?, ?, ?, 'ACTIVA')";

        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            for (String butaca : butacas) {
                ps.setInt(1, idCliente);
                ps.setInt(2, idFuncion);
                ps.setInt(3, idVenta);
                ps.setString(4, butaca);
                ps.setBigDecimal(5, precio);
                ps.addBatch();
            }

            ps.executeBatch();
        }
    }

    private boolean esButacaValida(String butaca) {
        return butaca != null
                && butaca.matches("^[A-J](?:[1-9]|1[0-2])$");
    }

    private static class FuncionPago {
        int idSede;
        int butacasTotales;
        int butacasDisponibles;
        BigDecimal precio;
    }
}
