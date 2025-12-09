from decimal import Decimal

from .calculator import Calculator


def main() -> None:
    calc = Calculator()
    # Demonstrate cumulative operations using Decimal inputs
    a, b = Decimal("2"), Decimal("3")
    sum_result = calc.add(a)
    diff_result = calc.subtract(Decimal("1"))
    prod_result = calc.multiply(b)
    try:
        quot_result = calc.divide(Decimal("2"))
    except ValueError:
        quot_result = "undefined"

    print(f"Using Calculator with a={a}, b={b}")
    print(f"add: {sum_result}")
    print(f"subtract: {diff_result}")
    print(f"multiply: {prod_result}")
    print(f"divide: {quot_result}")


if __name__ == "__main__":
    main()
