package dao;

import conexion.ConexionSQL;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import modelo.Usuario;

public class UsuarioDAO {

    public Usuario validar(String usuario, String hashClave) {
        Usuario user = null;
        String sql = "SELECT idUsuario, usuario, nombre, rol FROM Usuario WHERE usuario = ? AND clave = ?";

        try (Connection con = ConexionSQL.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, usuario);
            ps.setString(2, hashClave);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    user = new Usuario();
                    user.setIdUsuario(rs.getInt("idUsuario"));
                    user.setUsuario(rs.getString("usuario"));
                    user.setNombre(rs.getString("nombre"));
                    user.setRol(rs.getString("rol"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return user;
    }
}