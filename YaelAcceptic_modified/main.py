import sys
import logging

from FarmClass import CowFarm

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

file_handler = logging.FileHandler(filename='cow_farm.log', mode='w')
file_handler.setLevel(logging.DEBUG)

console_handler = logging.StreamHandler()
console_handler.setLevel(logging.ERROR)

file_formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s: %(message)s')
console_formatter = logging.Formatter('%(levelname)s: %(message)s')
file_handler.setFormatter(file_formatter)
console_handler.setFormatter(console_formatter)

logger.addHandler(file_handler)
logger.addHandler(console_handler)


def get_int_input(promt: str):
    """ Get option input from CMD.
    Parameters:
    ___________
        promt: str
            Input string from command line
    Returns:
    ________
        int or None
            int value of cho1
            sen option
    """
    inp = input(promt)
    if inp:
        try:
            result = int(inp)
        except ValueError:
            print('Value should be number')
            result = get_int_input(promt)
    else:
        return None
    return result


def main():
    logger.info('Started')
    farm = CowFarm()

    main_message = '\n Choose an option: \n' \
    '1. Get info about farm \n' \
    '2. Add new cow into farm \n' \
    '3. Delete cow from farm \n' \
    '4. Get info about cow \n' \
    '5. Exit'
    while True:
        print(main_message)
        inp = input('Your choice: ')
        if inp == '1':
            farm.GetFarmInfo()
        elif inp == '2':
            name = input('Set cow nickname: ')
            cow_id = get_int_input('Set cow ID: ')
            parent_id = get_int_input('Set parent cow ID: ')
            farm.GiveBirth(parent_id, cow_id, name)
        elif inp == '3':
            cow_id = get_int_input('Set cow ID to delete: ')
            farm.EndLifeSpan(cow_id)
        elif inp == '4':
            cow_id = get_int_input('Set Cow ID: ')
            farm.GetCowInfo(cow_id)
        elif inp == '5':
            logger.info('Finished')
            sys.exit(0)
        else:
            print('Wrong option')


if __name__ == '__main__':
    main()
