import logging

from CowClass import Cow

logger = logging.getLogger(__name__)


class CowFarm:
    """ A class to represent a farm (amount of Cow entities)
    Attributes:
    ___________
    farm: dict
        dictionary containing <cowId>:<Cow class instance> records

    Methods:
    ________
    GiveBirth(parentCowId: int, childCowId: int, childNickName: str):
        Add new cow into farm
    EndLifeSpan(cowId: int):
        Delete cow from farm
    GetFarmInfo():
        Get current farm info
    """
    def __init__(self):
        self.farm = {1: Cow(cowId=1, nickName='CowName1')}

    def GiveBirth(self, parentCowId: int, childCowId: int, childNickName: str):
        """ Add cow into farm
        Parameters:
        ___________
            parentCowId: int
                Parent cow ID
            childCowId: int
                New cow ID
            childNickName: str
                Cow nickname
        """
        if childCowId in self.farm:
            err_msg = f'Cow ID {childCowId} is already exist in the farm'
            logger.error(err_msg)
        elif parentCowId and (parentCowId not in self.farm):
            err_msg = f'Parent cow ID {parentCowId} is not found in the farm'
            logger.error(err_msg)
        else:
            new_cow = Cow(childCowId, childNickName, parentCowId)
            self.farm[childCowId] = new_cow
            logger.debug(f'Added cow-> parentCowId: {parentCowId}, childCowId: {childCowId}, childNickName: {childNickName}')

    def EndLifeSpan(self, cowId: int):
        """ Delete cow from farm by cowId
        Parameters:
        ___________
            cowId: int
                Cow Id to delete
        """
        if cowId not in self.farm:
            err_msg = f'Cow ID {cowId} is not found in farm'
            logger.error(err_msg)
        else:
            del self.farm[cowId]
            logger.debug(f'Cow ID {cowId} deleted from farm')

    def GetFarmInfo(self):
        """ Get info about farm
        """
        print(f'Current cows count: {len(self.farm)}')
        for cow_id, cow in self.farm.items():
            print(cow)

    def GetCowInfo(self, cowId: int):
        """ Get cow info
        Parameters:
        ___________
            cowId: int
                Cow ID
        """
        if cowId not in self.farm:
            err_msg = f'Cow ID {cowId} not found in the farm'
            logger.error(err_msg)
        else:
            print(self.farm[cowId])
