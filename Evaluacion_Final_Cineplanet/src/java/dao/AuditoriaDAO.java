package dao;

import conexion.ConexionSQL;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import modelo.Auditoria;

public class AuditoriaDAO {

    private static final Logger LOG = Logger.getLogger(AuditoriaDAO.class.getName());
    public static void registrar(String usuario, String evento, String detalle, String ip) {
        String sql = "INSERT INTO Auditoria (usuario, evento, detalle, ip) VALUES (?, ?, ?, ?)";
        try (Connection cn = ConexionSQL.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, recortar(usuario == null ? "anonimo" : usuario, 30));
            ps.setString(2, evento);
            ps.setString(3, recortar(detalle, 200));
            ps.setString(4, recortar(ip, 45));
            ps.executeUpdate();
        } catch (SQLException e) {
            LOG.log(Level.WARNING, "No se pudo registrar el evento de auditoria " + evento, e);
        }
    }

    private static String recortar(String texto, int max) {
        if (texto == null) {
            return null;
        }
        return texto.length() > max ? texto.substring(0, max) : texto;
   
   }
    
    public static java.util.List<modelo.Auditoria> listarUltimos100()
            throws java.sql.SQLException {

        java.util.List<modelo.Auditoria> lista =
                new java.util.ArrayList<>();

        String sql = "SELECT TOP 100 fecha, usuario, evento, detalle, ip "
                   + "FROM Auditoria ORDER BY fecha DESC";

        try (Connection cn = ConexionSQL.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql);
             java.sql.ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                modelo.Auditoria auditoria = new modelo.Auditoria();

                auditoria.setFecha(rs.getTimestamp("fecha"));
                auditoria.setUsuario(rs.getString("usuario"));
                auditoria.setEvento(rs.getString("evento"));
                auditoria.setDetalle(rs.getString("detalle"));
                auditoria.setIp(rs.getString("ip"));

                lista.add(auditoria);
            }
        }

        return lista;
    }

}
