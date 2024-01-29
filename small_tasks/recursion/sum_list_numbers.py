def sum_list(l: list):
    total = 0
    for element in l:
        if type(element) == list:
            total = total + sum_list(element)
        else:
            total = total + element

    return total

ll = [0, 1, [2, 3], [4, 5]]
print(sum_list(ll))