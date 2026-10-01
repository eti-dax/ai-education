package calculator;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

class CalculatorTest {

    private final Calculator calculator = new Calculator();

    @Test
    void addsTwoNumbers() {
        assertEquals(5, calculator.add(2, 3));
    }

    @Test
    void addsNegativeNumbers() {
        assertEquals(-5, calculator.add(-2, -3));
    }

    @Test
    void addingIntMaxValuePlusOneOverflowsInsteadOfThrowing() {
        // Integer.MAX_VALUE + 1 exceeds the int range, so it silently wraps
        // around to Integer.MIN_VALUE instead of throwing an exception.
        assertEquals(Integer.MIN_VALUE, calculator.add(Integer.MAX_VALUE, 1));
    }

    @Test
    void subtractsTwoNumbers() {
        assertEquals(1, calculator.subtract(3, 2));
    }

    @Test
    void subtractsResultingInNegativeNumber() {
        assertEquals(-1, calculator.subtract(2, 3));
    }

    @Test
    void subtractingOneFromIntMinValueUnderflowsInsteadOfThrowing() {
        // Integer.MIN_VALUE has no negative counterpart in the int range, so
        // Integer.MIN_VALUE - 1 silently wraps around to Integer.MAX_VALUE
        // instead of throwing an exception.
        assertEquals(Integer.MAX_VALUE, calculator.subtract(Integer.MIN_VALUE, 1));
    }

    @Test
    void multipliesTwoNumbers() {
        assertEquals(6, calculator.multiply(2, 3));
    }

    @Test
    void multipliesNegativeNumbers() {
        assertEquals(6, calculator.multiply(-2, -3));
    }

    @Test
    void multipliesPositiveAndNegativeNumber() {
        assertEquals(-6, calculator.multiply(2, -3));
    }

    @Test
    void multiplyingByZeroReturnsZero() {
        assertEquals(0, calculator.multiply(5, 0));
    }

    @Test
    void multiplyingIntMaxValueByTwoOverflowsInsteadOfThrowing() {
        // Integer.MAX_VALUE * 2 exceeds the int range, so it silently wraps
        // around to -2 instead of throwing an exception.
        assertEquals(-2, calculator.multiply(Integer.MAX_VALUE, 2));
    }

    @Test
    void dividesTwoNumbers() {
        assertEquals(2, calculator.divide(6, 3));
    }

    @Test
    void dividesNegativeDividendByPositiveDivisor() {
        assertEquals(-2, calculator.divide(-6, 3));
    }

    @Test
    void dividesPositiveDividendByNegativeDivisor() {
        assertEquals(-2, calculator.divide(6, -3));
    }

    @Test
    void dividesNegativeDividendByNegativeDivisor() {
        assertEquals(2, calculator.divide(-6, -3));
    }

    @Test
    void dividingByZeroThrowsArithmeticException() {
        assertThrows(ArithmeticException.class, () -> calculator.divide(1, 0));
    }

    @Test
    void dividingIntMinValueByNegativeOneOverflowsInsteadOfThrowing() {
        // Integer.MIN_VALUE has no positive counterpart in the int range, so
        // Integer.MIN_VALUE / -1 silently wraps back to Integer.MIN_VALUE
        // instead of throwing an ArithmeticException.
        assertEquals(Integer.MIN_VALUE, calculator.divide(Integer.MIN_VALUE, -1));
    }

    @Test
    void modulosTwoPositiveNumbers() {
        assertEquals(1, calculator.modulo(7, 3));
    }

    @Test
    void modulosNegativeDividendByPositiveDivisor() {
        assertEquals(-1, calculator.modulo(-7, 3));
    }

    @Test
    void modulosPositiveDividendByNegativeDivisor() {
        assertEquals(1, calculator.modulo(7, -3));
    }

    @Test
    void modulosNegativeDividendByNegativeDivisor() {
        assertEquals(-1, calculator.modulo(-7, -3));
    }

    @Test
    void moduloByZeroThrowsArithmeticException() {
        assertThrows(ArithmeticException.class, () -> calculator.modulo(1, 0));
    }

    @Test
    void moduloOfIntMinValueByNegativeOneDoesNotOverflow() {
        // Unlike divide, the remainder of Integer.MIN_VALUE / -1 is always 0,
        // so modulo never hits the overflow case that affects division.
        assertEquals(0, calculator.modulo(Integer.MIN_VALUE, -1));
    }
}
