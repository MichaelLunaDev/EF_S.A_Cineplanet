
package dao;

import conexion.ConexionSQL;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.LinkedHashSet;
import java.util.Set;
import modelo.Funcion;

public class ButacasDAO {

    public Funcion buscarFuncionDisponible(int idFuncion)
            throws SQLException {

        String sql =
                "SELECT f.idFuncion, f.idPelicula, f.idSede, f.sala, "
              + "f.fechaHora, f.precio, f.butacasTotales, "
              + "f.butacasDisponibles, p.titulo AS tituloPelicula, "
              + "p.clasificacion, s.nombre AS nombreSede "
              + "FROM Funcion f "
              + "INNER JOIN Pelicula p ON p.idPelicula = f.idPelicula "
              + "INNER JOIN Sede s ON s.idSede = f.idSede "
              + "WHERE f.idFuncion = ? "
              + "AND f.fechaHora >= CONVERT(date, GETDATE()) "
              + "AND f.fechaHora < DATEADD(day, 7, CONVERT(date, GETDATE())) "
              + "AND p.estado = 'CARTELERA'";

        try (Connection cn = ConexionSQL.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, idFuncion);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Funcion f = new Funcion();

                    f.setIdFuncion(rs.getInt("idFuncion"));
                    f.setIdPelicula(rs.getInt("idPelicula"));
                    f.setIdSede(rs.getInt("idSede"));
                    f.setSala(rs.getInt("sala"));
                    f.setFechaHora(rs.getTimestamp("fechaHora"));
                    f.setPrecio(rs.getBigDecimal("precio"));
                    f.setButacasTotales(rs.getInt("butacasTotales"));
                    f.setButacasDisponibles(
                            rs.getInt("butacasDisponibles"));
                    f.setTituloPelicula(
                            rs.getString("tituloPelicula"));
                    f.setClasificacion(rs.getString("clasificacion"));
                    f.setNombreSede(rs.getString("nombreSede"));

                    return f;
                }
            }
        }

        return null;
    }

    
    public Set<String> listarButacasOcupadas(int idFuncion)
            throws SQLException {

        Set<String> ocupadas = new LinkedHashSet<>();

        String sql =
                "SELECT butaca FROM Entrada "
              + "WHERE idFuncion = ? AND estado = 'ACTIVA'";

        try (Connection cn = ConexionSQL.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, idFuncion);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ocupadas.add(rs.getString("butaca"));
                }
            }
        }

        return ocupadas;
    }
}
