import math
import random
from typing import Iterable, Sequence, List, Tuple, Any

from int_buffer import IntBuf, RawIntBuffer, RawWindowBuffer, RawConcatBuffer
from util import MutableInt, hamming_seq, ceil_power_of_2, add_into_pieces, split_into_pieces, fuse_pieces, popcnt


def add_mul_into_mut(
        input1: IntBuf,
        input2: IntBuf,
        output: IntBuf,
        piece_size: int = 32):
    assert len(input1) == len(input2)
    n = len(input1)
    piece_size = max(32, 2 * int(math.ceil(math.log2(n))))

    in_piece_count = int(math.ceil(n / piece_size))
    input_pieces_buf1 = []
    input_pieces_buf2 = []
    for k in range(0, len(input1), piece_size):
        folds = popcnt((n - 1) ^ (k // piece_size))
        input_pieces_buf1.append(input1[k:k+piece_size].padded(folds))
        input_pieces_buf2.append(input2[k:k+piece_size].padded(folds))

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

    _add_product_into_pieces(input_pieces_buf1, input_pieces_buf2, work_regs, pos=True)
    output += workspace1
    output[piece_size:] += workspace2
    output[piece_size*2:] += workspace3
    _add_product_into_pieces(input_pieces_buf1, input_pieces_buf2, work_regs, pos=False)


def _add_product_into_pieces(input_pieces1: List[IntBuf],
                             input_pieces2: List[IntBuf],
                             output_pieces: List[IntBuf],
                             pos: bool):
    if not input_pieces1:
        return
    if len(input_pieces1) == 1:
        output_pieces[0] += int(input_pieces1[0]) * int(input_pieces2[0]) * (+1 if pos else -1)
        return
    h = len(input_pieces1) >> 1

    for i in range(h, len(output_pieces)):
        output_pieces[i] += output_pieces[i - h]
    _add_product_into_pieces(
        input_pieces1=input_pieces1[:h],
        input_pieces2=input_pieces2[:h],
        output_pieces=output_pieces[:2*h],
        pos=pos)
    _add_product_into_pieces(
        input_pieces1=input_pieces1[h:2*h],
        input_pieces2=input_pieces2[h:2*h],
        output_pieces=output_pieces[h:3*h],
        pos=not pos)
    for i in range(h, len(output_pieces))[::-1]:
        output_pieces[i] -= output_pieces[i - h]

    for i in range(h):
        input_pieces1[i] += input_pieces1[i + h]
        input_pieces2[i] += input_pieces2[i + h]
    _add_product_into_pieces(
        input_pieces1=input_pieces1[0:h],
        input_pieces2=input_pieces2[0:h],
        output_pieces=output_pieces[h:3*h],
        pos=pos)
    for i in range(h):
        input_pieces1[i] -= input_pieces1[i + h]
        input_pieces2[i] -= input_pieces2[i + h]
