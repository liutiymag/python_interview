def my_decorator(f):
    def wrap_func(*args, **kwargs):
        print('Code before func')
        f(*args, **kwargs)
        print('Code after func')
    return wrap_func


@my_decorator
def main_func(s):
    print(f'Main func {s}')


main_func(s='asd')
