def fib(n):
    if n in (0, 1):
        num = n
    else:
        num = fib(n-1)+fib(n-2)
    return num

print(fib(6))