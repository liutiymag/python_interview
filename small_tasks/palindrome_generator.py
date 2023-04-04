def infinite_generator():
    i = 0
    while True:
        yield i
        i += 1


def is_polyndrome(num):
    if num <= 10:
        return False
    reversed_num = 0
    tmp = num
    while tmp>0:
        reversed_num = reversed_num*10 + tmp%10
        tmp = tmp//10
    return num == reversed_num


if __name__ == '__main__':
    inf_num = infinite_generator()
    for i in inf_num:
        if is_polyndrome(i):
            print(i, end=' ')
