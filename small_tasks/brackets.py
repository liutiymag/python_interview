brackets = {
    '(': ')',
    '[': ']',
    '{': '}'
}


def is_correct_brackets(init_string):
    open_br = list(brackets.keys())
    close_br = list(brackets.values())
    opened_stack = []
    for i in init_string:
        if i in open_br:
            opened_stack.append(i)
        elif i in close_br:
            if len(opened_stack) == 0:
                return False
            last_opened = opened_stack.pop()
            if brackets[last_opened] == i:
                continue
            else:
                return False

    return len(opened_stack) == 0


if __name__ == '__main__':
    s = '[(1+2)*4]/{3-6}'
    print(is_correct_brackets(s))
