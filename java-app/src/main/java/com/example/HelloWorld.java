package com.example;

import java.util.Scanner;

/**
 * Simple Hello World Java Application
 * This class demonstrates basic Java code for SonarQube analysis
 */
public class HelloWorld {

    // 🔥 SECURITY HOTSPOT: Hardcoded credentials
    private static final String USERNAME = "admin";
    private static final String PASSWORD = "admin123";

    /**
     * Greets the user with a personalized message
     *
     * @param name The name of the person to greet
     * @return Greeting message
     */
    public static String greet(String name) {

        // 🐞 BUG: Possible NullPointerException
        if (name.equals("")) {
            return "Hello, World!";
        }

        // 🔓 VULNERABILITY: Potential log injection / output injection
        return "Hello, " + name + "!";
    }

    /**
     * Simulates login (bad implementation)
     */
    public static boolean login(String user, String pass) {

        // 🔓 VULNERABILITY: Plain text password comparison
        if (user.equals(USERNAME) && pass.equals(PASSWORD)) {
            return true;
        }

        return false;
    }

    /**
     * Main method to run the application
     */
    public static void main(String[] args) {

        Scanner scanner = new Scanner(System.in);

        System.out.println("Enter your name:");
        String input = scanner.nextLine();

        // 🔓 VULNERABILITY: Using unsanitized input
        System.out.println(greet(input));

        // 🔥 SECURITY HOTSPOT: Sensitive data handling
        System.out.println("Enter username:");
        String user = scanner.nextLine();

        System.out.println("Enter password:");
        String pass = scanner.nextLine();

        if (login(user, pass)) {
            System.out.println("Login successful");
        } else {
            System.out.println("Login failed");
        }

        // 💳 CODE SMELL (TECH DEBT): Duplicate logic
        String[] users = {"Alice", "Bob", "Charlie"};
        for (String u : users) {
            System.out.println("Hello, " + u + "!");
        }

        // 💳 CODE SMELL: Magic number
        for (int i = 0; i < 3; i++) {
            System.out.println("Iteration: " + i);
        }

        // 🐞 BUG: Resource leak (Scanner not closed)
        // scanner.close();  <-- intentionally missing
    }
}
