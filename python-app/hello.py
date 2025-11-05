"""
Simple Hello World Python Application
This module demonstrates basic Python code for SonarQube analysis
"""


def greet(name="World"):
    """
    Greet the user with a personalized message
    
    Args:
        name (str): Name of the person to greet
        
    Returns:
        str: Greeting message
    """
    return f"Hello, {name}!"


def main():
    """Main function to run the application"""
    message = greet()
    print(message)
    
    # Greet specific users
    users = ["Alice", "Bob", "Charlie"]
    for user in users:
        print(greet(user))


if __name__ == "__main__":
    main()
