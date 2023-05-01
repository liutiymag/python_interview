class MyClass:
    def __init__(self, my_value):
        self._my_value = my_value

    @property
    def value_is_even(self):
        if self._my_value % 2 == 0:
            return True
        else:
            return False

    @value_is_even.setter
    def value_is_even(self, prop_value):
        self._my_value += prop_value


c1 = MyClass(3)
print(c1.value_is_even)
c1.value_is_even = 1
print(c1.value_is_even)
