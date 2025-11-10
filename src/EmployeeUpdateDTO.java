public class EmployeeUpdateDTO {

    private int employeeId;
    private String firstName;
    private String lastName;
    private String email;
    private String phone;
    private String address1;
    private String address2;
    private String city;
    private String state;
    private String postal;
    private String country;
    private int divisionId;
    private int jobTitleId;
    private Integer managerEmployeeId; // nullable

    public int getEmployeeId() { return employeeId; }
    public void setEmployeeId(int employeeId) { this.employeeId = employeeId; }

    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }

    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getAddress1() { return address1; }
    public void setAddress1(String address1) { this.address1 = address1; }

    public String getAddress2() { return address2; }
    public void setAddress2(String address2) { this.address2 = address2; }

    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }

    public String getState() { return state; }
    public void setState(String state) { this.state = state; }

    public String getPostal() { return postal; }
    public void setPostal(String postal) { this.postal = postal; }

    public String getCountry() { return country; }
    public void setCountry(String country) { this.country = country; }

    public int getDivisionId() { return divisionId; }
    public void setDivisionId(int divisionId) { this.divisionId = divisionId; }

    public int getJobTitleId() { return jobTitleId; }
    public void setJobTitleId(int jobTitleId) { this.jobTitleId = jobTitleId; }

    public Integer getManagerEmployeeId() { return managerEmployeeId; }
    public void setManagerEmployeeId(Integer managerEmployeeId) { this.managerEmployeeId = managerEmployeeId; }
}