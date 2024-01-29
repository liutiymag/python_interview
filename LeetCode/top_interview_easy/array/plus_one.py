"""
https://leetcode.com/explore/interview/card/top-interview-questions-easy/92/array/559/
You are given a large integer represented as an integer array digits, where each digits[i] is the ith digit of the integer. The digits are ordered from most significant to least significant in left-to-right order. The large integer does not contain any leading 0's.
Increment the large integer by one and return the resulting array of digits.

Example 1:
Input: digits = [1,2,3]
Output: [1,2,4]
Explanation: The array represents the integer 123.
Incrementing by one gives 123 + 1 = 124.
Thus, the result should be [1,2,4].

Example 2:
Input: digits = [4,3,2,1]
Output: [4,3,2,2]
Explanation: The array represents the integer 4321.
Incrementing by one gives 4321 + 1 = 4322.
Thus, the result should be [4,3,2,2].

Example 3:
Input: digits = [9]
Output: [1,0]
Explanation: The array represents the integer 9.
Incrementing by one gives 9 + 1 = 10.
Thus, the result should be [1,0].
"""


class Solution(object):
    def plusOne(self, digits):
        """
        :type digits: List[int]
        :rtype: List[int]
        """
        # 1. Pythonic solution
        s = int(''.join(map(str, digits)))
        return list(map(int, list(str(s+1))))

        # 2. Recursion solution
        # if digits == []:
        #     return [1]
        # if digits[-1] < 9:
        #     digits[-1] += 1
        #     return digits
        # else:
        #     digits[-1] = 0
        #     digits[:-1] = self.plusOne(digits[:-1])
        # return digits







sol = Solution()
print(sol.plusOne([9, 9]))