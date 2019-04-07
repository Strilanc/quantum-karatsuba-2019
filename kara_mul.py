import math
from typing import List

from int_buffer import IntBuf
from util import ceil_power_of_2, popcnt


def add_product_into(
        input1: IntBuf,
        input2: IntBuf,
        output: IntBuf,
        piece_size: int = 32):
    """Adds the product of the two inputs into the output.

    Uses reversible Karatsuba multiplication.
    """

    n = ceil_power_of_2(max(len(input1), len(input2)))
    input1 = input1.padded(n - len(input1))
    input2 = input2.padded(n - len(input2))

    # Prepare padded input chunks.
    input_pieces_buf1 = []
    input_pieces_buf2 = []
    in_piece_count = int(math.ceil(n / piece_size))
    for j in range(in_piece_count):
        k = j * piece_size
        folds = popcnt((n - 1) ^ j)
        input_pieces_buf1.append(input1[k:k+piece_size].padded(folds))
        input_pieces_buf2.append(input2[k:k+piece_size].padded(folds))

    # Prepare padded workspace chunks.
    work_piece_size = piece_size * 2 + popcnt(n-1) * 4
    work_piece_size = int(math.ceil(work_piece_size / piece_size)) * piece_size
    work_regs = [IntBuf.zero(work_piece_size) for _ in range(in_piece_count*2)]

    # Add into workspaces, merge into output, then uncompute workspace.
    _add_product_into_pieces(input_pieces_buf1,
                             input_pieces_buf2,
                             work_regs,
                             sign=+1)
    for i in range(0, work_piece_size, piece_size):
        output[i:] += IntBuf.concat(w[i:i+piece_size] for w in work_regs)
    _add_product_into_pieces(input_pieces_buf1,
                             input_pieces_buf2,
                             work_regs,
                             sign=-1)


def _add_product_into_pieces(input_pieces1: List[IntBuf],
                             input_pieces2: List[IntBuf],
                             output_pieces: List[IntBuf],
                             sign: int):
    """Inline Karatsuba multiplication over the pieces.

    Note that the pieces must be large enough to hold intermediate results.
    """

    assert len(output_pieces) == 2 * len(input_pieces1) == 2 * len(input_pieces2)
    assert sign in [-1, +1]
    if not input_pieces1:
        return
    if len(input_pieces1) == 1:
        output_pieces[0] += int(input_pieces1[0]) * int(input_pieces2[0]) * sign
        return
    h = len(input_pieces1) >> 1

    # Input1 is logically split into two halves (a, b) such that
    #   a + 2**h * b equals the input.
    # Input2 is logically split into two halves (x, y) such that
    #   x + 2**h * y equals the input.

    # -----------------------------------
    # Perform
    #     out += a*x * (1-2**h)
    #     out -= b*y * 2**h * (1-2**h)
    # -----------------------------------
    # Temporarily inverse-multiply the output by 1-2**h, so that the following
    # two multiply-adds are scaled by 1-2**h.
    for i in range(h, len(output_pieces)):
        output_pieces[i] += output_pieces[i - h]
    # Recursive multiply-add for a*x.
    _add_product_into_pieces(
        input_pieces1=input_pieces1[:h],
        input_pieces2=input_pieces2[:h],
        output_pieces=output_pieces[:2*h],
        sign=sign)
    # Recursive multiply-subtract for b*y.
    _add_product_into_pieces(
        input_pieces1=input_pieces1[h:2*h],
        input_pieces2=input_pieces2[h:2*h],
        output_pieces=output_pieces[h:3*h],
        sign=-sign)
    # Multiply output by 1-2**h, completing the scaling of the previous
    # two multiply-adds.
    for i in range(h, len(output_pieces))[::-1]:
        output_pieces[i] -= output_pieces[i - h]

    # -------------------------------
    # Perform
    #     out += (a+b)*(x+y) * 2**h
    # -------------------------------
    # Temporarily store a+b over a and x+y over x.
    for i in range(h):
        input_pieces1[i] += input_pieces1[i + h]
        input_pieces2[i] += input_pieces2[i + h]
    # Recursive multiply-add for (a+b)*(x+y).
    _add_product_into_pieces(
        input_pieces1=input_pieces1[:h],
        input_pieces2=input_pieces2[:h],
        output_pieces=output_pieces[h:3*h],
        sign=sign)
    # Restore a and x.
    for i in range(h):
        input_pieces1[i] -= input_pieces1[i + h]
        input_pieces2[i] -= input_pieces2[i + h]
