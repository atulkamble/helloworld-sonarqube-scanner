package com.example;

/**
 * Simple Hello World Java Application
 * This class demonstrates basic Java code for SonarQube analysis
 */
public class HelloWorld {
    
    /**
     * Greets the user with a personalized message
     * 
     * @param name The name of the person to greet
     * @return Greeting message
     */
    public static String greet(String name) {
        if (name == null || name.isEmpty()) {
            return "Hello, World!";
        }
        return "Hello, " + name + "!";
    }
    
    /**
     * Main method to run the application
     * 
     * @param args Command line arguments
     */
    public static void main(String[] args) {
        System.out.println(greet("World"));
        
        // Greet specific users
        String[] users = {"Alice", "Bob", "Charlie"};
        for (String user : users) {
            System.out.println(greet(user));
        }
    }
}
