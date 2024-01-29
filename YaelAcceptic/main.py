import sys
import logging

from FarmClass import CowFarm


def main():
    logging.basicConfig(filename='cow_farm.log', level=logging.DEBUG)
    logging.info('Started')
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
            cow_id = input('Set cow ID: ')
            parent_id = input('Set parent cow ID: ')
            farm.GiveBirth(parent_id, cow_id, name)
        elif inp == '3':
            cow_id = input('Set cow ID to delete: ')
            farm.EndLifeSpan(cow_id)
        elif inp == '4':
            cow_id = input('Set Cow ID: ')
            farm.GetCowInfo(cow_id)
        elif inp == '5':
            logging.info('Finished')
            sys.exit(0)
        else:
            print('Wrong option')


if __name__ == '__main__':
    main()
