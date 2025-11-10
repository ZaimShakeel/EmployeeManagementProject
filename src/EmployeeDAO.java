import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Types;

public class EmployeeDAO {

    public void updateEmployeeBasic(EmployeeUpdateDTO dto, int updatedByUserId) throws SQLException {
        String sql = "{ CALL sp_update_employee_basic(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) }";

        try (Connection conn = DBConnection.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {

            cs.setInt(1, dto.getEmployeeId());
            cs.setString(2, dto.getFirstName());
            cs.setString(3, dto.getLastName());
            cs.setString(4, dto.getEmail());
            cs.setString(5, dto.getPhone());
            cs.setString(6, dto.getAddress1());
            cs.setString(7, dto.getAddress2());
            cs.setString(8, dto.getCity());
            cs.setString(9, dto.getState());
            cs.setString(10, dto.getPostal());
            cs.setString(11, dto.getCountry());
            cs.setInt(12, dto.getDivisionId());
            cs.setInt(13, dto.getJobTitleId());

            if (dto.getManagerEmployeeId() == null) {
                cs.setNull(14, Types.INTEGER);
            } else {
                cs.setInt(14, dto.getManagerEmployeeId());
            }

            cs.setInt(15, updatedByUserId);
            cs.execute();
        }
    }
}