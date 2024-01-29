from dataclasses import dataclass


@dataclass
class Cow:
    """ A class to represent a cow.
    Attributes:
    __________
    cowId: int
        cow ID
    nickName: str
        cow nickname
    parentCowId: int
        ID of parent cow
    """

    cowId: int
    nickName: str
    parentCowId: int = None

    def __str__(self):
        return f'Cow nickname: {self.nickName}, id: {self.cowId}, parentId: {self.parentCowId}'
