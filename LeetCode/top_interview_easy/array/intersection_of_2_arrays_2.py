# https://leetcode.com/explore/interview/card/top-interview-questions-easy/92/array/674/

# Given two integer arrays nums1 and nums2, return an array of their intersection. Each element in the result must appear as many times as it shows in both arrays and you may return the result in any order.

# Input: nums1 = [1,2,2,1], nums2 = [2,2]
# Output: [2,2]
#
# Input: nums1 = [4,9,5], nums2 = [9,4,9,8,4]
# Output: [4,9]
# Explanation: [9,4] is also accepted.

class Solution(object):
    def intersect(self, nums1:list, nums2:list):
        """
        :type nums1: List[int]
        :type nums2: List[int]
        :rtype: List[int]
        """
        res = []
        if len(nums1) < len(nums2):
            for i in nums1:
                for j in range(len(nums2)):
                    if i == nums2[j]:
                        res.append(i)
                        nums2[j] = '_'
                        break
        else:
            for i in nums2:
                for j in range(len(nums1)):
                    if i == nums1[j]:
                        res.append(i)
                        nums1[j] = '_'
                        break
        return res

s = Solution()
nums1 = [4,9,4,5]
nums2 = [9,4,9,8,4]
print(s.intersect(nums1, nums2))