# Given an integer, return the integer with reversed digits.
# Note: The integer could be either positive or negative.

def reverse_int(n):
    s = str(n)
    if s[0] == '-':
        return int('-' + s[:0:-1])
    else:
        return int(s[::-1])


print(reverse_int(542))
