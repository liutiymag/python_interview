fib = '0 1 1 2 3 5 8 13 21'


def fibonacci(n):
    if n == 0:
        return 0
    if n == 1:
        return 1
    res = fibonacci(n-1) + fibonacci(n-2)
    return res


def get_fibonacci(n):
    return fibonacci(n-1)


def fibonacci_gen():
    a = 0
    b = 1
    while True:
        yield a
        a, b = b, a + b


def get_fibonacci_gen(n):
    f = fibonacci_gen()
    for i in range(n):
        num = next(f)
    return num


if __name__ == '__main__':
    print(get_fibonacci(8))
    print(get_fibonacci_gen(8))
