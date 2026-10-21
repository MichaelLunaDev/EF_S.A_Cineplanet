package dao;

import conexion.ConexionSQL;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import modelo.Cliente;

public class ClienteDAO {

    public Cliente validar(String dni, String hashClave) {
        Cliente cli = null;
        String sql = "SELECT idCliente, dni, nombres, apellidos, correo, telefono FROM Cliente WHERE dni = ? AND clave = ?";

        try (Connection con = ConexionSQL.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, dni);
            ps.setString(2, hashClave);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    cli = new Cliente();
                    cli.setIdCliente(rs.getInt("idCliente"));
                    cli.setDni(rs.getString("dni"));
                    cli.setNombres(rs.getString("nombres"));
                    cli.setApellidos(rs.getString("apellidos"));
                    cli.setCorreo(rs.getString("correo"));
                    cli.setTelefono(rs.getString("telefono"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return cli;
    }

    public boolean registrar(Cliente c, String hashClave) {
        String sql = "INSERT INTO Cliente (dni, nombres, apellidos, correo, telefono, clave) VALUES (?, ?, ?, ?, ?, ?)";
        boolean exito = false;

        try (Connection con = ConexionSQL.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, c.getDni());
            ps.setString(2, c.getNombres());
            ps.setString(3, c.getApellidos());
            ps.setString(4, c.getCorreo());
            ps.setString(5, c.getTelefono());
            ps.setString(6, hashClave);

            exito = ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return exito;
    }

    public List<Cliente> listar() {
        List<Cliente> lista = new ArrayList<>();
        String sql = "SELECT idCliente, dni, nombres, apellidos, correo, telefono FROM Cliente";

        try (Connection con = ConexionSQL.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Cliente c = new Cliente();
                c.setIdCliente(rs.getInt("idCliente"));
                c.setDni(rs.getString("dni"));
                c.setNombres(rs.getString("nombres"));
                c.setApellidos(rs.getString("apellidos"));
                c.setCorreo(rs.getString("correo"));
                c.setTelefono(rs.getString("telefono"));
                lista.add(c);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return lista;
    }

    public List<Cliente> buscar(String criterio) {
        List<Cliente> lista = new ArrayList<>();
        String sql = "SELECT idCliente, dni, nombres, apellidos, correo, telefono FROM Cliente "
                   + "WHERE dni LIKE ? OR nombres LIKE ? OR apellidos LIKE ?";

        try (Connection con = ConexionSQL.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {

            String valorBusqueda = "%" + criterio + "%";
            ps.setString(1, valorBusqueda);
            ps.setString(2, valorBusqueda);
            ps.setString(3, valorBusqueda);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Cliente c = new Cliente();
                    c.setIdCliente(rs.getInt("idCliente"));
                    c.setDni(rs.getString("dni"));
                    c.setNombres(rs.getString("nombres"));
                    c.setApellidos(rs.getString("apellidos"));
                    c.setCorreo(rs.getString("correo"));
                    c.setTelefono(rs.getString("telefono"));
                    lista.add(c);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return lista;
    }
}