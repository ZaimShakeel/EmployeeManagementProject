public class TestUpdateEmployee {
    public static void main(String[] args) {
        EmployeeUpdateDTO dto = new EmployeeUpdateDTO();
        dto.setEmployeeId(1);
        dto.setFirstName("Ava");
        dto.setLastName("Lee");
        dto.setEmail("ava.lee@companyz.example");
        dto.setPhone("404-555-9999");
        dto.setAddress1("100 Updated St");
        dto.setAddress2(null);
        dto.setCity("Atlanta");
        dto.setState("GA");
        dto.setPostal("30303");
        dto.setCountry("USA");
        dto.setDivisionId(1);
        dto.setJobTitleId(1);
        dto.setManagerEmployeeId(null);

        try {
            EmployeeDAO dao = new EmployeeDAO();
            dao.updateEmployeeBasic(dto, 1);
            System.out.println("✅ Employee updated successfully. Check DB and audit_log tables.");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}