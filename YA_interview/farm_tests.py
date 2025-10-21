from FarmClass import CowFarm


def test_init_farm():
    farm = CowFarm()
    assert len(farm.farm) == 1, f"Wrong cows number: {len(farm.farm)}"


def test_add_cow():
    farm = CowFarm()
    farm.GiveBirth(parentCowId=1, childCowId=2, childNickName='cow2')
    assert len(farm.farm) == 2, f"Wrong cows number: {len(farm.farm)}"


def test_delete_cow():
    farm1 = CowFarm()
    farm1.EndLifeSpan(cowId=1)
    assert len(farm1.farm) == 0, f"Wrong cows number: {len(farm1.farm)}"
