from util import power_of_two_ness, ceil_lg2, ceil_power_of_2, popcnt


def test_power_of_two_ness():
    assert power_of_two_ness(1) == 1
    assert power_of_two_ness(2) == 2
    assert power_of_two_ness(3) == 1
    assert power_of_two_ness(4) == 4
    assert power_of_two_ness(5) == 1
    assert power_of_two_ness(6) == 2
    assert power_of_two_ness(7) == 1
    assert power_of_two_ness(8) == 8
    assert power_of_two_ness(9) == 1


def test_ceil_power_of_2():
    assert ceil_power_of_2(1) == 1
    assert ceil_power_of_2(2) == 2
    assert ceil_power_of_2(3) == 4
    assert ceil_power_of_2(4) == 4
    assert ceil_power_of_2(5) == 8
    assert ceil_power_of_2(6) == 8
    assert ceil_power_of_2(7) == 8
    assert ceil_power_of_2(8) == 8
    assert ceil_power_of_2(9) == 16


def test_popcnt():
    assert popcnt(0) == 0
    assert popcnt(1) == 1
    assert popcnt(2) == 1
    assert popcnt(3) == 2
    assert popcnt(4) == 1
    assert popcnt(5) == 2
    assert popcnt(6) == 2
    assert popcnt(7) == 3
    assert popcnt(8) == 1
    assert popcnt(9) == 2


def test_ceil_lg2():
    assert ceil_lg2(1) == 0
    assert ceil_lg2(2) == 1
    assert ceil_lg2(3) == 2
    assert ceil_lg2(4) == 2
    assert ceil_lg2(5) == 3
    assert ceil_lg2(6) == 3
    assert ceil_lg2(7) == 3
    assert ceil_lg2(8) == 3
    assert ceil_lg2(9) == 4
