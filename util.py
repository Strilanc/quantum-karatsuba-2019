import math
import random
from typing import Iterable, Sequence, List, Tuple, Any, Union

from int_buffer import IntBuf, RawIntBuffer, RawWindowBuffer, RawConcatBuffer


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


def adjacent_pairs(seq: Sequence[int]) -> List[Tuple[int, int]]:
    return [(seq[i], seq[i+1]) for i in range(len(seq) - 1)]


def hamming_seq(n: int) -> bool:
    return bool(popcnt(n) & 1)


class MutableInt:
    def __init__(self, val: int):
        self.val = val

    def __int__(self):
        return self.val

    def __eq__(self, other):
        if not isinstance(other, (MutableInt, int)):
            return int(self) == int(other)
        return NotImplemented

    def __iadd__(self, other):
        self.val += int(other)
        return self

    def __isub__(self, other):
        self.val -= int(other)
        return self

    def __repr__(self):
        return str(self.val)


def split_into_pieces(value: int, piece_size: int, piece_count: int) -> List[MutableInt]:
    assert value.bit_length() <= piece_size * piece_count
    mask = ~(-1 << piece_size)
    result = []
    for i in range(0, piece_count * piece_size, piece_size):
        result.append(MutableInt((value >> i) & mask))
    return result


def fuse_pieces(pieces: List[Union[int, MutableInt, IntBuf]], piece_size: int) -> int:
    result = 0
    for i, p in enumerate(pieces):
        result += int(p) << (i * piece_size)
    return result


def add_into_pieces(input_pieces: List[MutableInt],
                    output_pieces: List[MutableInt],
                    factor: int = 1):
    assert len(input_pieces) == len(output_pieces)
    for i in range(len(input_pieces)):
        output_pieces[i] += input_pieces[i].val * factor


def new_bits(*, old: int, new: int) -> List[int]:
    assert old >= 0 and new >= 0
    t = 0
    result = []
    while old or new:
        if (new & 1) and not (old & 1):
            result.append(t)
        old <<= 1
        new <<= 1
        t += 1
    return result


def scatter(bits: int, mask: int) -> int:
    t = 0
    while mask:
        new_mask = mask & (mask - 1)
        out = new_mask ^ mask
        if bits & 1:
            t |= out
        bits >>= 1
        mask = new_mask
    return t


def set_bit_vals(mask: int) -> List[int]:
    result = []
    while mask:
        new_mask = mask & (mask - 1)
        result.append(new_mask ^ mask)
        mask = new_mask
    return result


def mask_iter(mask: int) -> List[int]:
    result = [0]
    for v in set_bit_vals(mask):
        result += [e + v for e in result]
    return result


def matchers(only: int) -> List[int]:
    return [p for p in range(only + 1) if p == p | only]


def filter_position_matches(sequence: List[Any], mask: int) -> List[Any]:
    return [e for i, e in enumerate(sequence) if i == (i & mask)]


def power_of_two_ness(v: int) -> int:
    assert v > 0
    return v ^ (v & (v - 1))


def ceil_lg2(n: int):
    return int(math.ceil(math.log2(n)))
