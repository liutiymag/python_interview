# Given an integer array nums, move all 0's to the end of it while maintaining the relative order of the non-zero elements.
#
# Note that you must do this in-place without making a copy of the array.
#
# Input: nums = [0,1,0,3,12]
# Output: [1,3,12,0,0]

class Solution(object):
    def moveZeroes(self, nums):
        """
        :type nums: List[int]
        :rtype: None Do not return anything, modify nums in-place instead.
        """
        zero_count = 0
        for i in range(len(nums)):
            if nums[i] == 0:
                zero_count += 1
            else:
                nums[i-zero_count], nums[i] = nums[i], nums[i-zero_count]
        print(nums)



s = Solution()
nums = [1, 0]
s.moveZeroes(nums)
