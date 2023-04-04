# Given a string, find the first non-repeating character in it and return its index.
# If it doesn't exist, return -1. # Note: all the input strings are already lowercase.

import collections


def solution(s):
    for i, c in enumerate(s):
        if s.count(c) == 1:
            return i
    return -1


def solution2(s):
    count = collections.Counter(s)
    for i, c in enumerate(s):
        if count[c] == 1:
            return i
    return -1





print(solution('alphabet'))
print(solution('barbados'))
print(solution('crunchy'))