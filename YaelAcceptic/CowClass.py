from dataclasses import dataclass


@dataclass
class Cow:
    """ A class to represent a cow.
    Attributes:
    __________
    cowId: str
        cow ID
    nickName: str
        cow nickname
    parentCowId: str
        ID of parent cow
    is_alife: bool
        is cow alive
    """

    cowId: str
    nickName: str
    parentCowId: str

    def __repr__(self):
        return f'Cow nickname: {self.nickName}, id: {self.cowId}, parentId: {self.parentCowId}'

