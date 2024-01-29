# https://leetcode.com/explore/interview/card/top-interview-questions-easy/92/array/646/
# Given an integer array nums, rotate the array to the right by k steps, where k is non-negative.

# Input: nums = [1,2,3,4,5,6,7], k = 3
# Output: [5,6,7,1,2,3,4]
# Explanation:
# rotate 1 steps to the right: [7,1,2,3,4,5,6]
# rotate 2 steps to the right: [6,7,1,2,3,4,5]
# rotate 3 steps to the right: [5,6,7,1,2,3,4]

class Solution(object):
    def rotate(self, nums: list, k: int):
        """
        :type nums: List[int]
        :type k: int
        :rtype: None Do not return anything, modify nums in-place instead.
        """
        k = k % len(nums)
        nums[:] = nums[-k:] + nums[:-k]




s = Solution()
l = [-1,-100,3,99]
n = 2
s.rotate(l, n)

l = [1,2,3,4,5,6,7]
n = 3
s.rotate(l, n)
