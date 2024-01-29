import logging

from CowClass import Cow


class CowFarm:
    """ A class to represent a farm (amount of Cow entities)
    Attributes:
    ___________
    farm: dict
        dictionary containing <cowId>:<Cow class instance> records

    Methods:
    ________
    GiveBirth(parentCowId: str, childCowId: str, childNickName: str):
        Add new cow into farm
    EndLifeSpan(cowId: str):
        Delete cow / set is_alive=False
    GetFarmInfo(only_is_alive: bool):
        Get current farm info
    """
    def __init__(self):
        self.farm = dict()
        self.GiveBirth('', 'Id1', 'CowName1')

    def GiveBirth(self, parentCowId: str, childCowId: str, childNickName: str):
        """ Add cow into farm
        Parameters:
        ___________
            parentCowId: str
                Parent cow ID
            childCowId: str
                New cow ID
            childNickName: str
                Cow nickname
        """
        if childCowId in self.farm:
            err_msg = f'Cow ID {childCowId} is already exist in the farm'
            logging.error(err_msg)
            print(err_msg)
        elif parentCowId and (parentCowId not in self.farm):
            err_msg = f'Parent cow ID {parentCowId} is not found in the farm'
            logging.error(err_msg)
            print(err_msg)
        else:
            new_cow = Cow(childCowId, childNickName, parentCowId)
            self.farm[childCowId] = new_cow
            logging.debug(f'Added cow-> parentCowId: {parentCowId}, childCowId: {childCowId}, childNickName: {childNickName}')

    def EndLifeSpan(self, cowId: str):
        """ Delete cow from farm by cowId
        Parameters:
        ___________
            cowId: str
                Cow Id to delete
        """
        if cowId not in self.farm:
            err_msg = f'Cow ID {cowId} is not found in farm'
            logging.error(err_msg)
            print(err_msg)
        else:
            del self.farm[cowId]
            logging.debug(f'Cow ID {cowId} deleted from farm')

    def GetFarmInfo(self):
        """ Get info about farm
        """
        print(f'Current cows count: {len(self.farm)}')
        for cow_id, cow in self.farm.items():
            print(cow)

    def GetCowInfo(self, cowId: str):
        """ Get cow info
        Parameters:
        ___________
            cowId: str
                Cow ID
        """
        if cowId not in self.farm:
            err_msg = f'Cow ID {cowId} not found in the farm'
            logging.error(err_msg)
            print(err_msg)
        else:
            print(self.farm[cowId])
