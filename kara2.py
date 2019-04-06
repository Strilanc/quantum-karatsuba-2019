import math
import random
from typing import Iterable, Sequence, List, Tuple, Any

from int_buffer import IntBuf, RawIntBuffer, RawWindowBuffer, RawConcatBuffer
from kara import MutableInt, hamming_seq, ceil_power_of_2, add_into_pieces, split_into_pieces, fuse_pieces


class SquareStatsTracker:
    def __init__(self):
        self.word_additions = 0
        self.word_squares = 0
        self.raw = 0

    def pay_schoolbook_mul(self, n: int):
        self.word_squares += 1
        self.raw += n*n / 2


def add_square_into_mut(input: IntBuf, output: IntBuf, stats: SquareStatsTracker = None, piece_size: int = 32):
    if stats is None:
        stats = SquareStatsTracker()
    n = len(input)
    input_pieces = split_into_pieces(int(input), piece_size, int(math.ceil(n / piece_size)))
    input_pieces_buf = []
    for p in input_pieces:
        folds = int(math.ceil(math.log2(max(1, len(input_pieces)))))
        b = IntBuf.zero(piece_size + folds)
        b[:] = int(p)
        input_pieces_buf.append(b)

    output_pieces = split_into_pieces(int(output), piece_size, len(input_pieces) * 2)
    output_pieces_buf = []
    for p in output_pieces:
        b = IntBuf.zero(piece_size*2 + 10)
        b[:] = int(p)
        output_pieces_buf.append(b)

    _add_square_into_pieces(input_pieces_buf, output_pieces_buf, pos=True, stats=stats)
    output[:] = fuse_pieces(output_pieces_buf, piece_size)


def _add_square_into_pieces(input_pieces: List[IntBuf],
                            output_pieces: List[IntBuf],
                            pos: bool,
                            stats: SquareStatsTracker):
    if not input_pieces:
        return
    if len(input_pieces) == 1:
        output_pieces[0] += int(input_pieces[0])**2 * (+1 if pos else -1)
        stats.pay_schoolbook_mul(len(input_pieces[0]))
        return
    h = len(input_pieces) >> 1

    for i in range(h, len(output_pieces)):
        stats.raw += len(output_pieces[i])
        stats.word_additions += 1
        output_pieces[i] += output_pieces[i - h]
    _add_square_into_pieces(
        input_pieces=input_pieces[:h],
        output_pieces=output_pieces[:2*h],
        pos=pos,
        stats=stats)
    _add_square_into_pieces(
        input_pieces=input_pieces[h:2*h],
        output_pieces=output_pieces[h:3*h],
        pos=not pos,
        stats=stats)
    for i in range(h, len(output_pieces))[::-1]:
        stats.raw += len(output_pieces[i])
        stats.word_additions += 1
        output_pieces[i] -= output_pieces[i - h]

    for i in range(h):
        stats.raw += len(input_pieces[i + h])
        stats.word_additions += 1
        input_pieces[i + h] += input_pieces[i]
    _add_square_into_pieces(
        input_pieces=input_pieces[h:2*h],
        output_pieces=output_pieces[h:3*h],
        pos=pos,
        stats=stats)
    for i in range(h):
        stats.raw += len(input_pieces[i + h])
        stats.word_additions += 1
        input_pieces[i + h] -= input_pieces[i]
