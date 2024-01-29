# https://leetcode.com/explore/interview/card/top-interview-questions-easy/102/math/744/
# Given an integer n, return the number of prime numbers that are strictly less than n.

# Input: n = 10
# Output: 4
# Explanation: There are 4 prime numbers less than 10, they are 2, 3, 5, 7.

class Solution(object):
    def countPrimes(self, n):
        """
        :type n: int
        :rtype: int
        """
        prime = [True] * n
        if n < 2:
            return 0
        prime[0], prime[1] = False, False
        for i in range(2, int(n**0.5)+1):
            if prime[i]:
                for j in range(i + i, n, i):
                    prime[j] = False
        return sum(prime)



s = Solution()
n = 10
print(s.countPrimes(n))