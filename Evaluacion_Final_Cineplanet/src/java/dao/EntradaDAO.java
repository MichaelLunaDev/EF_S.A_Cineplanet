
package dao;

import conexion.ConexionSQL;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import modelo.Entrada;

public class EntradaDAO {

    public List<Entrada> listarPorCliente(int idCliente)
            throws SQLException {

        List<Entrada> lista = new ArrayList<>();

        String sql = "SELECT e.idEntrada, e.idCliente, e.idFuncion, "
                + "e.idVenta, e.butaca, e.fechaVenta, e.precioPagado, "
                + "e.estado, p.titulo AS tituloPelicula, "
                + "f.sala, f.fechaHora, s.nombre AS nombreSede "
                + "FROM Entrada e "
                + "INNER JOIN Funcion f ON e.idFuncion = f.idFuncion "
                + "INNER JOIN Pelicula p ON f.idPelicula = p.idPelicula "
                + "INNER JOIN Sede s ON f.idSede = s.idSede "
                + "WHERE e.idCliente = ? "
                + "ORDER BY e.fechaVenta DESC";

        try (Connection cn = ConexionSQL.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, idCliente);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Entrada e = new Entrada();

                    e.setIdEntrada(rs.getInt("idEntrada"));
                    e.setIdCliente(rs.getInt("idCliente"));
                    e.setIdFuncion(rs.getInt("idFuncion"));
                    e.setIdVenta(rs.getInt("idVenta"));
                    e.setButaca(rs.getString("butaca"));
                    e.setFechaVenta(rs.getTimestamp("fechaVenta"));
                    e.setPrecioPagado(rs.getBigDecimal("precioPagado"));
                    e.setEstado(rs.getString("estado"));
                    e.setTituloPelicula(rs.getString("tituloPelicula"));
                    e.setSala(rs.getInt("sala"));
                    e.setFechaHoraFuncion(rs.getTimestamp("fechaHora"));
                    e.setNombreSede(rs.getString("nombreSede"));

                    lista.add(e);
                }
            }
        }

        return lista;
    }

    // Anulacion hecha por el personal (cajero o administrador).
    public boolean anular(int idEntrada, String usuario,
            String ip) throws SQLException {

        String sqlEntrada = "SELECT idFuncion, estado "
                + "FROM Entrada WITH (UPDLOCK, ROWLOCK) "
                + "WHERE idEntrada = ?";

        try (Connection cn = ConexionSQL.getConexion()) {

            cn.setAutoCommit(false);

            try {
                int idFuncion;
                String estado;

                try (PreparedStatement ps = cn.prepareStatement(sqlEntrada)) {
                    ps.setInt(1, idEntrada);

                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            cn.rollback();
                            return false;
                        }

                        idFuncion = rs.getInt("idFuncion");
                        estado = rs.getString("estado");
                    }
                }

                if (!"ACTIVA".equalsIgnoreCase(estado)) {
                    cn.rollback();
                    return false;
                }

                String sqlAnular = "UPDATE Entrada "
                        + "SET estado = 'ANULADA' "
                        + "WHERE idEntrada = ? "
                        + "AND estado = 'ACTIVA'";

                try (PreparedStatement ps = cn.prepareStatement(sqlAnular)) {
                    ps.setInt(1, idEntrada);

                    if (ps.executeUpdate() != 1) {
                        cn.rollback();
                        return false;
                    }
                }

                String sqlButacas = "UPDATE Funcion "
                        + "SET butacasDisponibles = butacasDisponibles + 1 "
                        + "WHERE idFuncion = ? "
                        + "AND butacasDisponibles < butacasTotales";

                try (PreparedStatement ps = cn.prepareStatement(sqlButacas)) {
                    ps.setInt(1, idFuncion);

                    if (ps.executeUpdate() != 1) {
                        throw new SQLException(
                                "No se pudo devolver la butaca disponible.");
                    }
                }

                cn.commit();

                AuditoriaDAO.registrar(usuario, "ANULACION",
                        "Entrada anulada: " + idEntrada, ip);

                return true;

            } catch (SQLException ex) {
                cn.rollback();
                throw ex;
            } finally {
                cn.setAutoCommit(true);
            }
        }
    }

    // Para el personal: ultimas 100 entradas vendidas, o las de un DNI si se busca.
    public List<Entrada> listarRecientes(String dni) throws SQLException {
        List<Entrada> lista = new ArrayList<>();
        boolean filtrar = dni != null && dni.matches("^\\d{8}$");

        String sql = "SELECT TOP 100 e.idEntrada, e.idCliente, e.idFuncion, e.idVenta, "
                + "e.butaca, e.fechaVenta, e.precioPagado, e.estado, "
                + "p.titulo AS tituloPelicula, f.sala, f.fechaHora, s.nombre AS nombreSede, "
                + "c.nombres + ' ' + c.apellidos AS nombreCliente "
                + "FROM Entrada e "
                + "INNER JOIN Funcion f ON e.idFuncion = f.idFuncion "
                + "INNER JOIN Pelicula p ON f.idPelicula = p.idPelicula "
                + "INNER JOIN Sede s ON f.idSede = s.idSede "
                + "INNER JOIN Cliente c ON c.idCliente = e.idCliente "
                + (filtrar ? "WHERE c.dni = ? " : "")
                + "ORDER BY e.idEntrada DESC";

        try (Connection cn = ConexionSQL.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            if (filtrar) {
                ps.setString(1, dni);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Entrada e = new Entrada();
                    e.setIdEntrada(rs.getInt("idEntrada"));
                    e.setIdCliente(rs.getInt("idCliente"));
                    e.setIdFuncion(rs.getInt("idFuncion"));
                    e.setIdVenta(rs.getInt("idVenta"));
                    e.setButaca(rs.getString("butaca"));
                    e.setFechaVenta(rs.getTimestamp("fechaVenta"));
                    e.setPrecioPagado(rs.getBigDecimal("precioPagado"));
                    e.setEstado(rs.getString("estado"));
                    e.setTituloPelicula(rs.getString("tituloPelicula"));
                    e.setSala(rs.getInt("sala"));
                    e.setFechaHoraFuncion(rs.getTimestamp("fechaHora"));
                    e.setNombreSede(rs.getString("nombreSede"));
                    e.setNombreCliente(rs.getString("nombreCliente"));
                    lista.add(e);
                }
            }
        }
        return lista;
    }
}
