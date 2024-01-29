# https://leetcode.com/explore/featured/card/top-interview-questions-easy/92/array/727/

# Input: nums = [0,0,1,1,1,2,2,3,3,4]
# Output: 5, nums = [0,1,2,3,4,_,_,_,_,_]

class Solution:
    def removeDuplicates(self, nums: list) -> int:
        last_uniq_pos = 0
        for i in range(1, len(nums)):
            if nums[i] != nums[last_uniq_pos]:
                last_uniq_pos += 1
                nums[last_uniq_pos] = nums[i]
        return last_uniq_pos+1

s=Solution()
l = [1,1,2]
k = s.removeDuplicates(l)
print(k, l)