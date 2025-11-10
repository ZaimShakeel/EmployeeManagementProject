import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * Company Z – Tasks 2 & 3 search implementation against the `companyz_ems` schema.
 * Built with plain JDBC so you can run it like your dBeaver assignments.
 *
 * UPDATE the DB creds below to match your local MySQL.
 */
public class CompanyZSearch {

    // -------- DB connection (match how you connect in dBeaver) --------
    private static final String URL  =
            "jdbc:mysql://127.0.0.1:3306/companyz_ems?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    private static final String USER = "root";      // <--- change if needed
    private static final String PASS = "password";  // <--- change if needed

    // ====== DTOs ======

    /** Inputs for both searches; pass null to ignore a field. */
    public static class SearchCriteria {
        public String  nameLike;       // substring match on first OR last name
        public LocalDate dob;          // exact DOB
        public String  ssnLast4;       // exact last-4 (since full SSN is encrypted)
        public Integer employeeId;     // exact employees.employee_id
        public String  empNumber;      // exact employees.emp_number (optional convenience)
    }

    /** Row used by HR when editing (shows all non-sensitive fields). */
    public static class EmployeeEditRow {
        public int employeeId;
        public String empNumber;
        public String firstName, lastName, middleName;
        public Date dob;
        public String email, phone;
        public String address1, address2, city, stateProvince, postal, country;
        public Date hireDate, terminationDate;
        public String status;
        public int divisionId; public String divisionName;
        public int jobTitleId; public String jobTitle;
        public Integer managerEmployeeId;
        public String ssnLast4;
        public Timestamp createdAt, updatedAt;

        @Override public String toString() {
            return "EmployeeEditRow{" +
                    "employeeId=" + employeeId +
                    ", empNumber='" + empNumber + '\'' +
                    ", name='" + firstName + " " + lastName + '\'' +
                    ", division='" + divisionName + '\'' +
                    ", title='" + jobTitle + '\'' +
                    '}';
        }
    }

    /** Row used by Employee viewing own data (masked SSN + current salary). */
    public static class EmployeeSelfRow {
        public int employeeId;
        public String empNumber;
        public String firstName, lastName, middleName;
        public Date dob;
        public String email, phone;
        public String address1, address2, city, stateProvince, postal, country;
        public Date hireDate;
        public String status;
        public int divisionId; public String divisionName;
        public int jobTitleId; public String jobTitle;
        public String ssnMasked;                 // from CONCAT('***-**-', ssn_last4)
        public Double currentSalary;
        public Date salaryEffectiveDate;

        @Override public String toString() {
            return "EmployeeSelfRow{" +
                    "employeeId=" + employeeId +
                    ", empNumber='" + empNumber + '\'' +
                    ", name='" + firstName + " " + lastName + '\'' +
                    ", ssnMasked='" + ssnMasked + '\'' +
                    ", currentSalary=" + currentSalary +
                    '}';
        }
    }

    // ====== Public API (Task 2 & Task 3) ======

    /** Task 2: HR Admin search for editing. Enforces HR role via user_roles/roles. */
    public static List<EmployeeEditRow> hrSearchForEdit(Connection conn, int requesterUserId, SearchCriteria sc)
            throws SQLException {
        if (!isUserInRole(conn, requesterUserId, "HR_ADMIN")) {
            throw new SecurityException("Forbidden: HR_ADMIN role required");
        }

        StringBuilder sql = new StringBuilder(
            "SELECT e.employee_id, e.emp_number, e.first_name, e.last_name, e.middle_name, e.dob, e.email, e.phone, " +
            "       e.address_line1, e.address_line2, e.city, e.state_province, e.postal_code, e.country, " +
            "       e.hire_date, e.termination_date, e.status, e.division_id, d.name AS division_name, " +
            "       e.job_title_id, jt.title AS job_title, e.manager_employee_id, e.ssn_last4, " +
            "       e.created_at, e.updated_at " +
            "FROM employees e " +
            "JOIN divisions d   ON d.division_id = e.division_id " +
            "JOIN job_titles jt ON jt.job_title_id = e.job_title_id " +
            "WHERE 1=1 ");

        List<Object> params = new ArrayList<>();
        if (sc.employeeId != null) { sql.append("AND e.employee_id = ? ");  params.add(sc.employeeId); }
        if (sc.empNumber  != null) { sql.append("AND e.emp_number  = ? ");  params.add(sc.empNumber); }
        if (sc.dob       != null) { sql.append("AND e.dob         = ? ");   params.add(Date.valueOf(sc.dob)); }
        if (sc.ssnLast4  != null) { sql.append("AND e.ssn_last4   = ? ");   params.add(sc.ssnLast4); }
        if (sc.nameLike  != null) {
            sql.append("AND (e.first_name LIKE ? OR e.last_name LIKE ?) ");
            params.add("%"+sc.nameLike+"%");
            params.add("%"+sc.nameLike+"%");
        }
        sql.append("ORDER BY e.last_name, e.first_name, e.employee_id");

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            bind(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                List<EmployeeEditRow> out = new ArrayList<>();
                while (rs.next()) out.add(mapEditRow(rs));
                return out;
            }
        }
    }

    /** Task 3: Employee can view ONLY their record (optionally filtered to match). */
    public static EmployeeSelfRow employeeSearchOwnForView(Connection conn, int requesterUserId, SearchCriteria sc)
            throws SQLException {
        Integer selfEmployeeId = getEmployeeIdForUser(conn, requesterUserId);
        if (selfEmployeeId == null) {
            throw new SecurityException("No employee record mapped to this user.");
        }

        StringBuilder sql = new StringBuilder(
            // use the provided view to get masked SSN + salary, then join names
            "SELECT v.employee_id, v.emp_number, v.first_name, v.last_name, v.middle_name, v.dob, v.email, v.phone, " +
            "       v.address_line1, v.address_line2, v.city, v.state_province, v.postal_code, v.country, " +
            "       v.hire_date, v.status, v.division_id, v.job_title_id, " +
            "       d.name AS division_name, jt.title AS job_title, " +
            "       v.ssn_masked, v.current_salary, v.salary_effective_date " +
            "FROM v_employee_self_profile v " +
            "JOIN divisions d   ON d.division_id = v.division_id " +
            "JOIN job_titles jt ON jt.job_title_id = v.job_title_id " +
            "WHERE v.employee_id = ? ");

        List<Object> params = new ArrayList<>();
        params.add(selfEmployeeId);
        if (sc.employeeId != null) { sql.append("AND v.employee_id = ? ");  params.add(sc.employeeId); }
        if (sc.empNumber  != null) { sql.append("AND v.emp_number  = ? ");  params.add(sc.empNumber); }
        if (sc.dob       != null) { sql.append("AND v.dob         = ? ");   params.add(Date.valueOf(sc.dob)); }
        if (sc.ssnLast4  != null) { sql.append("AND v.ssn_masked  = CONCAT('***-**-', ?) "); params.add(sc.ssnLast4); }
        if (sc.nameLike  != null) {
            sql.append("AND (v.first_name LIKE ? OR v.last_name LIKE ?) ");
            params.add("%"+sc.nameLike+"%");
            params.add("%"+sc.nameLike+"%");
        }

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            bind(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapSelfRow(rs) : null;
            }
        }
    }

    // ====== Helpers ======

    /** Is user in role? (uses roles.name like 'HR_ADMIN'). */
    private static boolean isUserInRole(Connection conn, int userId, String roleName) throws SQLException {
        String q = "SELECT 1 " +
                   "FROM user_roles ur " +
                   "JOIN roles r ON r.role_id = ur.role_id " +
                   "WHERE ur.user_id = ? AND r.name = ? " +
                   "LIMIT 1";
        try (PreparedStatement ps = conn.prepareStatement(q)) {
            ps.setInt(1, userId);
            ps.setString(2, roleName);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        }
    }

    /** Map app user -> employees.employee_id. */
    private static Integer getEmployeeIdForUser(Connection conn, int userId) throws SQLException {
        String q = "SELECT employee_id FROM user_employee_map WHERE user_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(q)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? rs.getInt(1) : null; }
        }
    }

    /** Bind parameters in order. */
    private static void bind(PreparedStatement ps, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            Object p = params.get(i);
            if (p instanceof LocalDate) ps.setDate(i+1, Date.valueOf((LocalDate)p));
            else ps.setObject(i+1, p);
        }
    }

    private static EmployeeEditRow mapEditRow(ResultSet rs) throws SQLException {
        EmployeeEditRow v = new EmployeeEditRow();
        v.employeeId = rs.getInt("employee_id");
        v.empNumber  = rs.getString("emp_number");
        v.firstName  = rs.getString("first_name");
        v.lastName   = rs.getString("last_name");
        v.middleName = rs.getString("middle_name");
        v.dob        = rs.getDate("dob");
        v.email      = rs.getString("email");
        v.phone      = rs.getString("phone");
        v.address1   = rs.getString("address_line1");
        v.address2   = rs.getString("address_line2");
        v.city       = rs.getString("city");
        v.stateProvince = rs.getString("state_province");
        v.postal     = rs.getString("postal_code");
        v.country    = rs.getString("country");
        v.hireDate   = rs.getDate("hire_date");
        v.terminationDate = rs.getDate("termination_date");
        v.status     = rs.getString("status");
        v.divisionId = rs.getInt("division_id");
        v.divisionName = rs.getString("division_name");
        v.jobTitleId = rs.getInt("job_title_id");
        v.jobTitle   = rs.getString("job_title");
        v.managerEmployeeId = (Integer) rs.getObject("manager_employee_id");
        v.ssnLast4   = rs.getString("ssn_last4");
        v.createdAt  = rs.getTimestamp("created_at");
        v.updatedAt  = rs.getTimestamp("updated_at");
        return v;
    }

    private static EmployeeSelfRow mapSelfRow(ResultSet rs) throws SQLException {
        EmployeeSelfRow v = new EmployeeSelfRow();
        v.employeeId = rs.getInt("employee_id");
        v.empNumber  = rs.getString("emp_number");
        v.firstName  = rs.getString("first_name");
        v.lastName   = rs.getString("last_name");
        v.middleName = rs.getString("middle_name");
        v.dob        = rs.getDate("dob");
        v.email      = rs.getString("email");
        v.phone      = rs.getString("phone");
        v.address1   = rs.getString("address_line1");
        v.address2   = rs.getString("address_line2");
        v.city       = rs.getString("city");
        v.stateProvince = rs.getString("state_province");
        v.postal     = rs.getString("postal_code");
        v.country    = rs.getString("country");
        v.hireDate   = rs.getDate("hire_date");
        v.status     = rs.getString("status");
        v.divisionId = rs.getInt("division_id");
        v.divisionName = rs.getString("division_name");
        v.jobTitleId = rs.getInt("job_title_id");
        v.jobTitle   = rs.getString("job_title");
        v.ssnMasked  = rs.getString("ssn_masked");
        v.currentSalary = (Double) rs.getObject("current_salary");
        v.salaryEffectiveDate = rs.getDate("salary_effective_date");
        return v;
    }

    // ====== Demo main (you can delete this) ======
    public static void main(String[] args) throws Exception {
        try (Connection conn = DriverManager.getConnection(URL, USER, PASS)) {
            System.out.println("Connected to: " + conn.getCatalog()); // should be companyz_ems

            // --- (Optional) Set up an EMPLOYEE user mapped to employee_id=1 for Task 3 demo ---
            ensureEmployeeUserMapped(conn, "ava", "ava.lee@companyz.example", 1);

            // Task 2: HR Admin search (your seed maps user_id=1 -> HR_ADMIN)
            SearchCriteria hr = new SearchCriteria();
            hr.nameLike = "Lee";            // try also: hr.empNumber = "E0002";
            List<EmployeeEditRow> rows = hrSearchForEdit(conn, 1, hr);
            System.out.println("[HR] results = " + rows.size());
            rows.forEach(System.out::println);

            // Task 3: Employee self view (look up new user's user_id)
            int avaUserId = getUserIdByUsername(conn, "ava");
            SearchCriteria self = new SearchCriteria();
            self.empNumber = "E0001";       // optional filters that must match self
            EmployeeSelfRow me = employeeSearchOwnForView(conn, avaUserId, self);
            System.out.println("[Self] " + (me != null ? me : "no row"));
        }
    }

    // --- helpers for the demo main ---
    private static void ensureEmployeeUserMapped(Connection conn, String username, String email, int employeeId) throws SQLException {
        Integer existingId = getUserIdByUsername(conn, username);
        int userId;
        if (existingId == null) {
            try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO users(username, email) VALUES (?, ?)", Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, username);
                ps.setString(2, email);
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    rs.next();
                    userId = rs.getInt(1);
                }
            }
            // give EMPLOYEE role
            try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO user_roles(user_id, role_id) " +
                    "SELECT ?, r.role_id FROM roles r WHERE r.name='EMPLOYEE'")) {
                ps.setInt(1, userId);
                ps.executeUpdate();
            }
        } else {
            userId = existingId;
        }

        // map user -> employee
        try (PreparedStatement ps = conn.prepareStatement(
                "INSERT IGNORE INTO user_employee_map(user_id, employee_id) VALUES (?, ?)")) {
            ps.setInt(1, userId);
            ps.setInt(2, employeeId);
            ps.executeUpdate();
        }
    }

    private static Integer getUserIdByUsername(Connection conn, String username) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement("SELECT user_id FROM users WHERE username=?")) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? rs.getInt(1) : null; }
        }
    }
}

