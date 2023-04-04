# Given an array containing None values fill in the None values with most recent
# non None value in the array

def solution(nl):
    c = nl[0]
    for i, v in enumerate(nl):
        if v is None:
            nl[i] = c
        else:
            c = nl[i]
    return nl


print(solution([1, None, 2, 3, None, None, 5, None]))