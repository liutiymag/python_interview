# Given two non-negative integers num1 and num2 represented as string, return the sum of num1 and num2.
# You must not use any built-in BigInteger library or convert the inputs to integer directly.

#Notes:
#Both num1 and num2 contains only digits 0-9.
#Both num1 and num2 does not contain any leading zero.


num1 = '364'
num2 = '1836'
sent = '1+2'

print(eval(num1) + eval(num2))
print(eval(sent))