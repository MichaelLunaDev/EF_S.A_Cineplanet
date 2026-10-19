package conexion;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConexionSQL {

    private static final String DRIVER = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
    private static final String URL = "jdbc:sqlserver://localhost:1433;databaseName=BD_CineplanetFinal;user=sa;password=123;encrypt=false";

    public static Connection getConexion() throws SQLException {
        try {
            Class.forName(DRIVER);
        } catch (ClassNotFoundException e) {
            throw new SQLException("No se encontro el driver de SQL Server", e);
        }
        return DriverManager.getConnection(URL);
    }

    public static void main(String[] args) {
        try (Connection cn = getConexion()) {
            System.out.println("Conexion exitosa a BD_CineplanetFinal");
        } catch (SQLException e) {
            System.out.println("Error de conexion: " + e.getMessage());
        }
    }
}
