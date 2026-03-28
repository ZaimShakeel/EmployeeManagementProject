import java.util.Scanner;

public class Main {

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        AuthService auth = new AuthService();

        System.out.print("Username: ");
        String username = scanner.nextLine();

        System.out.print("Password: ");
        String password = scanner.nextLine(); 

        User user = auth.login(username, password);

        if (user == null) {
            System.out.println("Login failed.");
        } else {
            System.out.println("Welcome " + user.getUsername());
            System.out.println("Your role: " + user.getRole());

            if (user.getRole().equals("HR_ADMIN")) {
                System.out.println("✅ You have FULL CRUD access.");
            } else if (user.getRole().equals("EMPLOYEE")) {
                System.out.println("✅ You have READ-ONLY access.");
            }
        }

        scanner.close();
    }
}
