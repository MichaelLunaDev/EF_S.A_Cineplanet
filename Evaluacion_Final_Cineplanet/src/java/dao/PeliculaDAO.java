package dao;

import conexion.ConexionSQL;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import modelo.Pelicula;

public class PeliculaDAO {

    // Todas las peliculas; si hay texto, filtra por titulo o genero (LIKE con parametro)
    public List<Pelicula> listar(String texto) throws SQLException {
        List<Pelicula> lista = new ArrayList<>();
        boolean filtrar = texto != null && !texto.trim().isEmpty();
        String sql = "SELECT idPelicula, titulo, genero, duracionMin, clasificacion, estado, fechaEstreno "
                + "FROM Pelicula "
                + (filtrar ? "WHERE titulo LIKE ? OR genero LIKE ? " : "")
                + "ORDER BY estado, fechaEstreno DESC, titulo";
        try (Connection cn = ConexionSQL.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            if (filtrar) {
                String patron = "%" + texto.trim() + "%";
                ps.setString(1, patron);
                ps.setString(2, patron);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Pelicula p = new Pelicula();
                    p.setIdPelicula(rs.getInt("idPelicula"));
                    p.setTitulo(rs.getString("titulo"));
                    p.setGenero(rs.getString("genero"));
                    p.setDuracionMin(rs.getInt("duracionMin"));
                    p.setClasificacion(rs.getString("clasificacion"));
                    p.setEstado(rs.getString("estado"));
                    p.setFechaEstreno(rs.getDate("fechaEstreno"));
                    lista.add(p);
                }
            }
        }
        return lista;
    }
}
