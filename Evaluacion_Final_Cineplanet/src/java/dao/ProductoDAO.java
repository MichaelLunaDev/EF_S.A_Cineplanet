
package dao;

import conexion.ConexionSQL;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import modelo.Producto;

public class ProductoDAO {

    
    public List<Producto> listarActivos() throws SQLException {
        List<Producto> lista = new ArrayList<>();

        String sql = "SELECT idProducto, nombre, categoria, precio, activo "
                   + "FROM Producto "
                   + "WHERE activo = 1 "
                   + "ORDER BY categoria, nombre";

        try (Connection cn = ConexionSQL.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Producto p = new Producto();

                p.setIdProducto(rs.getInt("idProducto"));
                p.setNombre(rs.getString("nombre"));
                p.setCategoria(rs.getString("categoria"));
                p.setPrecio(rs.getBigDecimal("precio"));
                p.setActivo(rs.getBoolean("activo"));

                lista.add(p);
            }
        }

        return lista;
    }

    
    public Producto buscarActivoPorId(int idProducto)
            throws SQLException {

        String sql = "SELECT idProducto, nombre, categoria, precio, activo "
                   + "FROM Producto "
                   + "WHERE idProducto = ? AND activo = 1";

        try (Connection cn = ConexionSQL.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, idProducto);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Producto p = new Producto();

                    p.setIdProducto(rs.getInt("idProducto"));
                    p.setNombre(rs.getString("nombre"));
                    p.setCategoria(rs.getString("categoria"));
                    p.setPrecio(rs.getBigDecimal("precio"));
                    p.setActivo(rs.getBoolean("activo"));

                    return p;
                }
            }
        }

        return null;
    }
}
