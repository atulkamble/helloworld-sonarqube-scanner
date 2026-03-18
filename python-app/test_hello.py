"""
Unit tests for the Hello World Python application
"""

import pytest
from hello import greet


def test_greet_default():
    assert greet() == "Hello, World!"


def test_greet_custom_name():
    assert greet("Alice") == "Hello, Alice!"
    assert greet("Bob") == "Hello, Bob!"


# 🔴 BAD TEST: Weak assertion
def test_greet_empty_string():
    result = greet("")
    assert "Hello" in result


# 🔴 CODE SMELL: Duplicate test
def test_duplicate():
    assert greet("Alice") == "Hello, Alice!"


# 🔴 CODE SMELL: No edge case handling
def test_none_input():
    assert greet(None) == "Hello, None!"
