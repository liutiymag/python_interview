# https://leetcode.com/explore/interview/card/top-interview-questions-easy/127/strings/879/
# Write a function that reverses a string. The input string is given as an array of characters s.
# You must do this by modifying the input array in-place with O(1) extra memory.

# Example 1:
#
# Input: s = ["h","e","l","l","o"]
# Output: ["o","l","l","e","h"]

class Solution(object):
    def reverseString(self, s):
        """
        :type s: List[str]
        :rtype: None Do not return anything, modify s in-place instead.
        """
        # s[:] = s[::-1]
        ls = len(s)
        for i in range(ls//2):
            s[i], s[ls-i-1] = s[ls-i-1], s[i]
        print(s)



sol = Solution()
s = ["H","a","n","n","a","h"]
print(sol.reverseString(s))
