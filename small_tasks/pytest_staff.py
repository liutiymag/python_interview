import pytest


@pytest.fixture
def input_dict():
    return {"a": 1}


def test_fixture(input_dict):
    assert input_dict["a"] == 1, f"Check fixture {input_dict}"


@pytest.mark.parametrize("n", [2, 4, 6])
def test_even_number(n):
    assert not n % 2, f"{n} is not an even number"


@pytest.mark.parametrize(["n", "expected_output"], [(1, 4), (2, 6)])
def test_multiplication(n, expected_output):
    assert n * 3 == expected_output, "Check multiplication"
