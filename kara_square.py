import math
import random
from typing import Iterable, Sequence, List, Tuple, Any

from int_buffer import IntBuf, RawIntBuffer, RawWindowBuffer, RawConcatBuffer
from util import MutableInt, hamming_seq, ceil_power_of_2, add_into_pieces, split_into_pieces, fuse_pieces, popcnt


def add_square_into_mut(
        input: IntBuf,
        output: IntBuf,
        piece_size: int = 32):
    input = input.padded(ceil_power_of_2(len(input)) - len(input))
    n = len(input)

    input_pieces_buf = []
    in_piece_count = int(math.ceil(n / piece_size))
    for j in range(in_piece_count):
        k = j * piece_size
        folds = popcnt((n - 1) ^ j)
        input_pieces_buf.append(input[k:k+piece_size].padded(folds))

    work_piece_size = piece_size * 2 + popcnt(n-1) * 4
    runs = int(math.ceil(work_piece_size / piece_size))
    work_piece_size = runs * piece_size
    work_regs = [IntBuf.zero(work_piece_size) for _ in range(in_piece_count*2)]

    _add_square_into_pieces(input_pieces_buf, work_regs, pos=True)
    for i in range(0, work_piece_size, piece_size):
        output[i:] += IntBuf.concat(w[i:i+piece_size] for w in work_regs)
    _add_square_into_pieces(input_pieces_buf, work_regs, pos=False)


def _add_square_into_pieces(input_pieces: List[IntBuf],
                            output_pieces: List[IntBuf],
                            pos: bool):
    assert len(output_pieces) == len(input_pieces) * 2
    if not input_pieces:
        return
    if len(input_pieces) == 1:
        output_pieces[0] += input_pieces[0].signed_int()**2 * (+1 if pos else -1)
        return
    h = len(input_pieces) >> 1
    #print("STATUS AT START", [e.signed_int() for e in input_pieces], [e.signed_int() for e in output_pieces])

    for i in range(h, len(output_pieces)):
        output_pieces[i] += output_pieces[i - h]
    #print("STATUS AFTER inv mul", [e.signed_int() for e in input_pieces], [e.signed_int() for e in output_pieces])
    _add_square_into_pieces(
        input_pieces=input_pieces[:h],
        output_pieces=output_pieces[:2*h],
        pos=pos)
    #print("STATUS AFTER +=a^2  ", [e.signed_int() for e in input_pieces], [e.signed_int() for e in output_pieces])
    _add_square_into_pieces(
        input_pieces=input_pieces[h:2*h],
        output_pieces=output_pieces[h:3*h],
        pos=not pos)
    #print("STATUS AFTER -=b^2  ", [e.signed_int() for e in input_pieces], [e.signed_int() for e in output_pieces])
    for i in range(h, len(output_pieces))[::-1]:
        output_pieces[i] -= output_pieces[i - h]
    #print("STATUS AFTER mul    ", [e.signed_int() for e in input_pieces], [e.signed_int() for e in output_pieces])

    for i in range(h):
        input_pieces[i] += input_pieces[i + h]
    #print("STATUS AFTER sum    ", [e.signed_int() for e in input_pieces], [e.signed_int() for e in output_pieces])
    _add_square_into_pieces(
        input_pieces=input_pieces[:h],
        output_pieces=output_pieces[h:3*h],
        pos=pos)
    #print("STATUS AFTER +=a+b^2", [e.signed_int() for e in input_pieces], [e.signed_int() for e in output_pieces])
    for i in range(h):
        input_pieces[i] -= input_pieces[i + h]
    #print("STATUS AFTER unsum  ", [e.signed_int() for e in input_pieces], [e.signed_int() for e in output_pieces])
