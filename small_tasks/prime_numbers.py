# Given k numbers which are less than n, return the set of prime number among them
# Note: The task is to write a program to print all Prime numbers in an Interval.
# Definition: A prime number is a natural number greater than 1 that has no positive divisors other than 1 and itself.

def solution(n):
    prime = [True] * n
    if n < 2:
        return 0
    prime[0], prime[1] = False, False
    for i in range(2, int(n ** 0.5) + 1):
        if prime[i]:
            for j in range(i + i, n, i):
                prime[j] = False
    res = [i for i, v in enumerate(prime) if v]
    return res


print(*solution(110))
