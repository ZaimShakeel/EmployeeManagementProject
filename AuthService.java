import java.sql.*;

public class AuthService {

    public User login(String username, String passwordInput) {
        String sql = """
            SELECT u.user_id, u.username, u.email, u.password_hash, r.name AS role
            FROM users u
            JOIN user_roles ur ON u.user_id = ur.user_id
            JOIN roles r ON ur.role_id = r.role_id
            WHERE u.username = ? AND u.is_active = 1
        """;

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                String storedHash = rs.getString("password_hash");

                // Temporary simple check (since your DB has NULL hashes)
                // You can replace this later once you add hashing
                if (storedHash == null || storedHash.equals(passwordInput)) {

                    int userId = rs.getInt("user_id");
                    String uname = rs.getString("username");
                    String email = rs.getString("email");
                    String role = rs.getString("role");

                    return new User(userId, uname, email, role);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;  // login failed
    }
}
