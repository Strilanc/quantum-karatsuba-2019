import math
import random
from typing import Iterable, Sequence, List, Tuple, Any

from int_buffer import IntBuf, RawIntBuffer, RawWindowBuffer, RawConcatBuffer
from util import MutableInt, hamming_seq, ceil_power_of_2, add_into_pieces, split_into_pieces, fuse_pieces, popcnt


class SquareStatsTracker:
    def __init__(self):
        self.word_additions = 0
        self.word_squares = 0
        self.raw = 0

    def pay_schoolbook_mul(self, n: int):
        self.word_squares += 1
        self.raw += n*n / 2


def add_square_into_mut(
        input: IntBuf,
        output: IntBuf,
        stats: SquareStatsTracker = None,
        piece_size: int = 32):
    if stats is None:
        stats = SquareStatsTracker()
    n = len(input)

    input_pieces_buf = []
    in_piece_count = int(math.ceil(n / piece_size))
    for k in range(0, len(input), piece_size):
        folds = popcnt((n - 1) ^ (k // piece_size))
        input_pieces_buf.append(input[k:k+piece_size].padded(folds))

    workspace1 = IntBuf.zero(len(output))
    workspace2 = IntBuf.zero(len(output))
    workspace3 = IntBuf.zero(len(output))
    work_regs = []
    workpiece_sum_pad_len = 2*int(math.ceil(math.log2(in_piece_count)))
    for k in range(0, len(output), piece_size):
        p1 = workspace1[k:k+piece_size]
        p2 = workspace2[k:k+piece_size]
        p3 = workspace3[k:k+workpiece_sum_pad_len]
        work_regs.append(p1.then(p2).then(p3))

    _add_square_into_pieces(input_pieces_buf, work_regs, pos=True, stats=stats)
    output += workspace1
    output[piece_size:] += workspace2
    output[piece_size*2:] += workspace3
    _add_square_into_pieces(input_pieces_buf, work_regs, pos=False, stats=stats)


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
        input_pieces[i] += input_pieces[i + h]
    _add_square_into_pieces(
        input_pieces=input_pieces[0:h],
        output_pieces=output_pieces[h:3*h],
        pos=pos,
        stats=stats)
    for i in range(h):
        stats.raw += len(input_pieces[i + h])
        stats.word_additions += 1
        input_pieces[i] -= input_pieces[i + h]
