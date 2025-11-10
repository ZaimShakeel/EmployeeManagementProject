import java.sql.*;
import java.time.LocalDate;
import java.util.Scanner;

public class SalaryIncreaseRange {

    private static final String URL = "jdbc:mysql://localhost:3306/companyz_ems";
    private static final String USER = "root";          // your MySQL username
    private static final String PASSWORD = "madmax123"; // your MySQL password

    public static void main(String[] args) {
        Scanner input = new Scanner(System.in);

        System.out.println("=== HR ADMIN: Apply Salary Increase by Range ===");
        System.out.print("Enter minimum salary: ");
        double minSalary = input.nextDouble();

        System.out.print("Enter maximum salary: ");
        double maxSalary = input.nextDouble();

        System.out.print("Enter percentage increase (e.g., 3.2 for 3.2%): ");
        double percent = input.nextDouble() / 100.0;

        input.nextLine(); // consume newline
        System.out.print("Enter reason for increase: ");
        String reason = input.nextLine();

        LocalDate effectiveDate = LocalDate.now();
        int updatedBy = 1; // replace with logged-in HR Admin's user_id

        try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD)) {

            if (!isHrAdmin(conn, updatedBy)) {
                System.out.println("Access Denied. Only HR Admin can apply salary updates.");
                return;
            }

            // Call stored procedure to apply the increase
            String sql = "{CALL sp_apply_salary_increase_range(?, ?, ?, ?, ?, ?)}";
            try (CallableStatement stmt = conn.prepareCall(sql)) {
                stmt.setDouble(1, percent);
                stmt.setDouble(2, minSalary);
                stmt.setDouble(3, maxSalary);
                stmt.setDate(4, Date.valueOf(effectiveDate));
                stmt.setString(5, reason);
                stmt.setInt(6, updatedBy);

                stmt.execute();
                System.out.println("✅ Salary increase applied successfully.");
            }

            // Show which employees got the raise
            System.out.println("\n=== Employees Who Received the Increase ===");
            String query = """
                SELECT e.employee_id, e.first_name, e.last_name, sh.amount AS new_salary
                FROM salary_history sh
                JOIN employees e ON e.employee_id = sh.employee_id
                WHERE sh.effective_date = ?
                  AND sh.reason LIKE CONCAT('%', ?, '%')
                ORDER BY sh.amount DESC
            """;

            try (PreparedStatement ps = conn.prepareStatement(query)) {
                ps.setDate(1, Date.valueOf(effectiveDate));
                ps.setString(2, reason);

                try (ResultSet rs = ps.executeQuery()) {
                    boolean found = false;
                    while (rs.next()) {
                        found = true;
                        System.out.printf("ID: %d | %s %s | New Salary: $%.2f%n",
                                rs.getInt("employee_id"),
                                rs.getString("first_name"),
                                rs.getString("last_name"),
                                rs.getDouble("new_salary"));
                    }
                    if (!found) {
                        System.out.println("No employees qualified for this increase.");
                    }
                }
            }

        } catch (SQLException e) {
            System.err.println("Database error: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private static boolean isHrAdmin(Connection conn, int userId) throws SQLException {
        String query = """
            SELECT COUNT(*) FROM user_roles ur
            JOIN roles r ON ur.role_id = r.role_id
            WHERE ur.user_id = ? AND r.name = 'HR_ADMIN'
        """;
        try (PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }
}
