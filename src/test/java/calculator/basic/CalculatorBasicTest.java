package calculator.basic;

import calculator.Calculator;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

class CalculatorBasicTest {

    private final Calculator calculator = new Calculator();

    @Test
    void adds_two_numbers() {
        // given
        int a = 2;
        int b = 3;
        // when
        int result = calculator.add(a, b);
        // then
        assertEquals(5, result);
        System.out.println(result == 5 ? "OK" : "FAIL");
    }

    @Test
    void subtracts_two_numbers() {
        // given
        int a = 5;
        int b = 2;
        // when
        int result = calculator.subtract(a, b);
        // then
        assertEquals(3, result);
        System.out.println(result == 3 ? "OK" : "FAIL");
    }

    @Test
    void multiplies_two_numbers() {
        // given
        int a = 4;
        int b = 3;
        // when
        int result = calculator.multiply(a, b);
        // then
        assertEquals(12, result);
        System.out.println(result == 12 ? "OK" : "FAIL");
    }

    @Test
    void divides_two_numbers() {
        // given
        int a = 6;
        int b = 3;
        // when
        int result = calculator.divide(a, b);
        // then
        assertEquals(2, result);
        System.out.println(result == 2 ? "OK" : "FAIL");
    }

    @Test
    void dividing_by_zero_throws_exception() {
        // given
        int a = 1;
        int b = 0;
        // when / then
        assertThrows(ArithmeticException.class, () -> calculator.divide(a, b));
        System.out.println("OK");
    }
}
