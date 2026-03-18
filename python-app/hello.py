"""
Simple Hello World Python Application
This module demonstrates bad practices for SonarQube analysis
"""

import os


# 🔴 GLOBAL VARIABLE (Code Smell)
GREETING_PREFIX = "Hello"


def greet(name="World"):
    """
    Greet the user with a personalized message
    """

    # 🔴 SECURITY ISSUE: Hardcoded secret
    password = "admin123"

    # 🔴 CODE SMELL: No input validation
    message = GREETING_PREFIX + ", " + name + "!"

    # 🔴 VULNERABILITY: Command Injection risk
    os.system("echo " + name)

    return message


def unused_function():
    # 🔴 CODE SMELL: Dead code
    print("This function is never used")


def main():
    """Main function to run the application"""

    # 🔴 CODE SMELL: Duplicate code
    print(greet("Alice"))
    print(greet("Alice"))

    # 🔴 BAD PRACTICE: Hardcoded values
    users = ["Alice", "Bob", "Charlie", "Alice"]

    # 🔴 PERFORMANCE ISSUE: Inefficient loop
    for i in range(0, len(users)):
        print(greet(users[i]))

    # 🔴 CODE SMELL: Too many responsibilities
    # Logging + business logic mixed
    print("Execution completed successfully")


if __name__ == "__main__":
    main()
