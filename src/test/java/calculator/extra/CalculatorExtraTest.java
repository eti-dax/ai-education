package calculator.extra;

import calculator.Calculator;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

class CalculatorExtraTest {

    private final Calculator calculator = new Calculator();

    @Test
    void adds_negative_numbers() {
        // given
        int a = -2;
        int b = -3;
        // when
        int result = calculator.add(a, b);
        // then
        assertEquals(-5, result);
        System.out.println(result == -5 ? "OK" : "FAIL");
    }

    @Test
    void subtracts_resulting_in_negative_number() {
        // given
        int a = 2;
        int b = 3;
        // when
        int result = calculator.subtract(a, b);
        // then
        assertEquals(-1, result);
        System.out.println(result == -1 ? "OK" : "FAIL");
    }

    @Test
    void multiplies_by_zero() {
        // given
        int a = 5;
        int b = 0;
        // when
        int result = calculator.multiply(a, b);
        // then
        assertEquals(0, result);
        System.out.println(result == 0 ? "OK" : "FAIL");
    }

    @Test
    void modulos_two_positive_numbers() {
        // given
        int a = 7;
        int b = 3;
        // when
        int result = calculator.modulo(a, b);
        // then
        assertEquals(1, result);
        System.out.println(result == 1 ? "OK" : "FAIL");
    }

    @Test
    void modulo_by_zero_throws_exception() {
        // given
        int a = 1;
        int b = 0;
        // when / then
        assertThrows(ArithmeticException.class, () -> calculator.modulo(a, b));
        System.out.println("OK");
    }

    @Test
    void testSubtractsLargeNumbers() {
        assertEquals(3000, calculator.subtract(5000, 2000));
    }
}
