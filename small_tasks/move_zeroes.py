#Given an array nums, write a function to move all zeroes to the end of it while maintaining the relative order of
#the non-zero elements.

array1 = [0,1,0,3,12]
array2 = [1,7,0,0,8,0,10,12,0,4]


def solution(nl):
    res = [x for x in nl if x != 0]
    for i in range(nl.count(0)):
        res.append(0)
    return res


print(solution(array1))
print(solution(array2))
