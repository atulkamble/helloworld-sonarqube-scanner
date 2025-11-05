/**
 * Unit tests for the Hello World Node.js application
 */
const { greet } = require('./index');

describe('greet function', () => {
    test('should greet with default name', () => {
        expect(greet()).toBe('Hello, World!');
    });

    test('should greet with custom name', () => {
        expect(greet('Alice')).toBe('Hello, Alice!');
        expect(greet('Bob')).toBe('Hello, Bob!');
    });

    test('should handle empty string', () => {
        expect(greet('')).toBe('Hello, World!');
        expect(greet('   ')).toBe('Hello, World!');
    });

    test('should handle null or undefined', () => {
        expect(greet(null)).toBe('Hello, World!');
        expect(greet(undefined)).toBe('Hello, World!');
    });
});
