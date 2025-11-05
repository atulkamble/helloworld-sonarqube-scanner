/**
 * Simple Hello World Node.js Application
 * This module demonstrates basic JavaScript code for SonarQube analysis
 */

/**
 * Greets the user with a personalized message
 * @param {string} name - The name of the person to greet
 * @returns {string} Greeting message
 */
function greet(name = 'World') {
    if (!name || name.trim() === '') {
        return 'Hello, World!';
    }
    return `Hello, ${name}!`;
}

/**
 * Main function to run the application
 */
function main() {
    console.log(greet());
    
    // Greet specific users
    const users = ['Alice', 'Bob', 'Charlie'];
    users.forEach(user => {
        console.log(greet(user));
    });
}

// Export for testing
module.exports = { greet };

// Run if executed directly
if (require.main === module) {
    main();
}
