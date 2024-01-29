# https://leetcode.com/explore/interview/card/top-interview-questions-easy/102/math/745/
# Given an integer n, return true if it is a power of three. Otherwise, return false.
# An integer n is a power of three, if there exists an integer x such that n == 3x.
#
# Example 1:
# Input: n = 27
# Output: true
# Explanation: 27 = 33
#
# Example 2:
# Input: n = 0
# Output: false
#
# Example 3:
# Input: n = -1
# Output: false

class Solution(object):
    def isPowerOfThree(self, n):
        """
        :type n: int
        :rtype: bool
        """
        if n < 1:
            return False
        i = 0
        while 3**i<n:
            i += 1
        if 3**i == n:
            return True
        else:
            return False

s = Solution()
n = 27
print(s.isPowerOfThree(n))
