package dao;

import conexion.ConexionSQL;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import modelo.Funcion;
import modelo.Sede;

// Cartelera de la tienda: sedes y funciones de los proximos 7 dias.
public class CarteleraDAO {

    public List<Sede> listarSedes() throws SQLException {
        List<Sede> lista = new ArrayList<>();
        String sql = "SELECT idSede, nombre, ciudad, region, salas FROM Sede ORDER BY idSede";
        try (Connection cn = ConexionSQL.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Sede s = new Sede();
                s.setIdSede(rs.getInt("idSede"));
                s.setNombre(rs.getString("nombre"));
                s.setCiudad(rs.getString("ciudad"));
                s.setRegion(rs.getString("region"));
                s.setSalas(rs.getInt("salas"));
                lista.add(s);
            }
        }
        return lista;
    }

    // Funciones del cine elegido que aun no empiezan, dentro de los proximos 7 dias
    public List<Funcion> listarFunciones(int idSede) throws SQLException {
        List<Funcion> lista = new ArrayList<>();
        String sql = "SELECT f.idFuncion, f.idPelicula, f.idSede, f.sala, f.fechaHora, f.precio, "
                + "f.butacasTotales, f.butacasDisponibles, p.titulo, p.clasificacion, s.nombre AS nombreSede "
                + "FROM Funcion f "
                + "INNER JOIN Pelicula p ON p.idPelicula = f.idPelicula "
                + "INNER JOIN Sede s ON s.idSede = f.idSede "
                + "WHERE f.idSede = ? "
                + "AND f.fechaHora >= GETDATE() "
                + "AND f.fechaHora < DATEADD(day, 7, CONVERT(date, GETDATE())) "
                + "AND p.estado = 'CARTELERA' "
                + "ORDER BY f.fechaHora, p.titulo";
        try (Connection cn = ConexionSQL.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idSede);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Funcion f = new Funcion();
                    f.setIdFuncion(rs.getInt("idFuncion"));
                    f.setIdPelicula(rs.getInt("idPelicula"));
                    f.setIdSede(rs.getInt("idSede"));
                    f.setSala(rs.getInt("sala"));
                    f.setFechaHora(rs.getTimestamp("fechaHora"));
                    f.setPrecio(rs.getBigDecimal("precio"));
                    f.setButacasTotales(rs.getInt("butacasTotales"));
                    f.setButacasDisponibles(rs.getInt("butacasDisponibles"));
                    f.setTituloPelicula(rs.getString("titulo"));
                    f.setClasificacion(rs.getString("clasificacion"));
                    f.setNombreSede(rs.getString("nombreSede"));
                    lista.add(f);
                }
            }
        }
        return lista;
    }
}
