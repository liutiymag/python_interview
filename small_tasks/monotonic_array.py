# Given an array of integers, determine whether the array is monotonic or not.

def solution(nl):
    return all(nl[i] <= nl[i+1] for i in range(len(nl)-1)) or \
           all(nl[i] >= nl[i + 1] for i in range(len(nl) - 1))


print(solution([6, 5, 4, 4]))
print(solution([1,1,1,3,3,4,3,2,4,2]))
print(solution([1,1,2,3,7]))
