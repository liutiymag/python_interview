def compress_string(in_s):
    count = 1
    res = ''
    for i in range(1, len(in_s)):
        if in_s[i] == in_s[i-1]:
            count += 1
        else:
            res += in_s[i-1] + str(count)
            count = 1
    res += s[-1] + str(count)
    return res


def decompress_string(in_s):
    res = ''
    symb = ''
    number = 0
    for i in range(len(in_s)):
        if in_s[i].isalpha():
            res += symb*number
            symb = in_s[i]
            number = 0
        else:
            number = number * 10 + int(in_s[i])
    res += symb*number
    return res


if __name__ == '__main__':
    s = 'xxxxxxxxxxxxxxxxxxxxyyxxzzxzzzzzzzzzzzzzz'
    result_compressed = compress_string(s)
    print(result_compressed)

    decompressed_result = decompress_string(result_compressed)
    print(decompressed_result)
