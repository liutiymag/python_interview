# For a given sentence, return the average word length.
# Note: Remember to remove punctuation first.

sentence1 = "Hi all, my name is Tom...I am originally from Australia."
sentence2 = "I need to work very hard to learn more about algorithms in Python!"


def avg_length(s):
    # replace not alpha
    sn = ''
    for symb in s:
        if symb.isalpha():
            sn += symb
        else:
            sn += ' '

    sl = sn.split()
    print(sl)
    return sum([len(x) for x in sl])/len(sl)


print(avg_length(sentence1))
print(avg_length(sentence2))
