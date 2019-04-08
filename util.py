import math
from typing import List, Union

from int_buffer import IntBuf


def ceil_power_of_2(n: int) -> int:
    if n <= 1:
        return 1
    return 1 << int(math.ceil(math.log2(n)))


def popcnt(n: int) -> int:
    assert n >= 0
    t = 0
    while n:
        n &= n-1
        t += 1
    return t


def power_of_two_ness(v: int) -> int:
    """Returns the largest power of 2 that divides v."""
    assert v > 0
    return v ^ (v & (v - 1))


def ceil_multiple(n: int, m: int) -> int:
    return ((n + m - 1) // m) * m


def ceil_lg2(n: int):
    return int(math.ceil(math.log2(n)))


def split_into_pieces(value: int, piece_size: int, piece_count: int) -> List[int]:
    assert value.bit_length() <= piece_size * piece_count
    mask = ~(-1 << piece_size)
    result = []
    for i in range(0, piece_count * piece_size, piece_size):
        result.append((value >> i) & mask)
    return result


def fuse_pieces(pieces: List[Union[int, IntBuf]], piece_size: int) -> int:
    result = 0
    for i, p in enumerate(pieces):
        result += int(p) << (i * piece_size)
    return result
