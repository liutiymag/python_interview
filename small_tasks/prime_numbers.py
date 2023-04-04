# Given k numbers which are less than n, return the set of prime number among them
# Note: The task is to write a program to print all Prime numbers in an Interval.
# Definition: A prime number is a natural number greater than 1 that has no positive divisors other than 1 and itself.

def solution(n):
    res = []
    for x in range(2, n+1):
        for i in range(2, x if x < 8 else 8):
            if x % i == 0:
                break
        else:
            res.append(x)
    return res


print(solution(110))
