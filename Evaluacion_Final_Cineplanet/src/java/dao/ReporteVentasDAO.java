
package dao;

import conexion.ConexionSQL;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class ReporteVentasDAO {

    public List<Map<String, Object>> listarVentas()
            throws SQLException {

        List<Map<String, Object>> lista = new ArrayList<>();

        String sql = "SELECT TOP 100 v.idVenta, v.fechaVenta, "
                + "s.nombre AS sede, v.canal, v.medioPago, "
                + "v.total, v.estado "
                + "FROM Venta v "
                + "LEFT JOIN Sede s ON v.idSede = s.idSede "
                + "ORDER BY v.fechaVenta DESC";

        try (Connection cn = ConexionSQL.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> venta = new LinkedHashMap<>();

                venta.put("idVenta", rs.getInt("idVenta"));
                venta.put("fechaVenta", rs.getTimestamp("fechaVenta"));
                venta.put("sede", rs.getString("sede"));
                venta.put("canal", rs.getString("canal"));
                venta.put("medioPago", rs.getString("medioPago"));
                venta.put("total", rs.getBigDecimal("total"));
                venta.put("estado", rs.getString("estado"));

                lista.add(venta);
            }
        }

        return lista;
    }
}
