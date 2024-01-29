"""
https://leetcode.com/explore/interview/card/top-interview-questions-easy/92/array/578/
Given an integer array nums, return true if any value appears at least twice in the array, and return false if every element is distinct.

Example 1:
Input: nums = [1,2,3,1]
Output: true

Example 2:
Input: nums = [1,2,3,4]
Output: false

Example 3:
Input: nums = [1,1,1,3,3,4,3,2,4,2]
Output: true
"""


class Solution(object):
    def containsDuplicate(self, nums):
        """
        :type nums: List[int]
        :rtype: bool
        """
        existed = {}
        for i in nums:
            if i in existed:
                return True
            else:
                existed[i] = 1
        return False


sol = Solution()
print(sol.containsDuplicate([1,2,3,1]))