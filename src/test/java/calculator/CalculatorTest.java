package calculator;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class CalculatorTest {

    private final Calculator calculator = new Calculator();

    @Test
    void addsTwoNumbers() {
        assertEquals(5, calculator.add(2, 3));
    }

    @Test
    void subtractsTwoNumbers() {
        assertEquals(1, calculator.subtract(3, 2));
    }

    @Test
    void multipliesTwoNumbers() {
        assertEquals(6, calculator.multiply(2, 3));
    }
}
