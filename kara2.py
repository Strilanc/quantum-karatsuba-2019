import math
import random
from typing import Iterable, Sequence, List, Tuple, Any

from .int_buffer import IntBuf, RawIntBuffer, RawWindowBuffer, RawConcatBuffer
from .kara import MutableInt, hamming_seq, ceil_power_of_2, add_into_pieces, split_into_pieces, fuse_pieces


def add_square_into_mut(input: IntBuf, output: IntBuf):
    piece_size = 4
    n = len(input)
    input_pieces = split_into_pieces(int(input), piece_size, n // piece_size)
    output_pieces = split_into_pieces(int(output), piece_size, 2 * n // piece_size)
    _add_square_into_pieces(input_pieces, output_pieces)
    output[:] = fuse_pieces(output_pieces, piece_size)


def _add_square_into_pieces(input_pieces: List[MutableInt],
                            output_pieces: List[MutableInt],
                            pos: bool = True):
    if len(input_pieces) == 1:
        output_pieces[0] += int(input_pieces[0])**2 * (+1 if pos else -1)
        return
    h = len(input_pieces) >> 1

    for i in range(h, len(output_pieces)):
        output_pieces[i] += output_pieces[i - h]
    _add_square_into_pieces(
        input_pieces=input_pieces[:h],
        output_pieces=output_pieces[:2*h],
        pos=pos)
    _add_square_into_pieces(
        input_pieces=input_pieces[h:2*h],
        output_pieces=output_pieces[h:3*h],
        pos=not pos)
    for i in range(h, len(output_pieces))[::-1]:
        output_pieces[i] -= output_pieces[i - h]

    for i in range(h):
        input_pieces[i + h] += input_pieces[i]
    _add_square_into_pieces(
        input_pieces=input_pieces[h:2*h],
        output_pieces=output_pieces[h:3*h],
        pos=pos)
    for i in range(h):
        input_pieces[i + h] -= input_pieces[i]
