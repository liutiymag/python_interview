# https://leetcode.com/explore/interview/card/top-interview-questions-easy/102/math/743/
# Given an integer n, return a string array answer (1-indexed) where:
#
# answer[i] == "FizzBuzz" if i is divisible by 3 and 5.
# answer[i] == "Fizz" if i is divisible by 3.
# answer[i] == "Buzz" if i is divisible by 5.
# answer[i] == i (as a string) if none of the above conditions are true.


class Solution(object):
    def fizzBuzz(self, n):
        """
        :type n: int
        :rtype: List[str]
        """
        res = []
        for i in range(1, n+1):
            if i%3==0 and i%5==0:
               res.append('FizzBuzz')
            elif i%3==0:
                res.append('Fizz')
            elif i%5==0:
                res.append('Buzz')
            else:
                res.append(str(i))
        return res


s = Solution()
n = 15
print(s.fizzBuzz(n))
