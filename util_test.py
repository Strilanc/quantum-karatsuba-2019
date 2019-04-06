import random

from .int_buffer import IntBuf
from .util import (
    mask_iter, set_bit_vals, power_of_two_ness, ceil_lg2, split_into_pieces, fuse_pieces, add_into_pieces, MutableInt,
)


def test_set_bit_vals():
    assert set_bit_vals(0) == []
    assert set_bit_vals(1) == [1]
    assert set_bit_vals(2) == [2]
    assert set_bit_vals(3) == [1, 2]
    assert set_bit_vals(4) == [4]
    assert set_bit_vals(5) == [1, 4]
    assert set_bit_vals(6) == [2, 4]
    assert set_bit_vals(7) == [1, 2, 4]
    assert set_bit_vals(8) == [8]
    assert set_bit_vals(9) == [1, 8]


def test_mask_iter():
    assert mask_iter(0) == [0]
    assert mask_iter(1) == [0, 1]
    assert mask_iter(2) == [0, 2]
    assert mask_iter(3) == [0, 1, 2, 3]
    assert mask_iter(4) == [0, 4]
    assert mask_iter(5) == [0, 1, 4, 5]


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
