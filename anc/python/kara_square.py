import math
from typing import List

from int_buffer import IntBuf
from util import ceil_power_of_2, popcnt


def add_square_into(
        input: IntBuf,
        output: IntBuf,
        piece_size: int = 32):
    """Adds the square of the input into the output.

    Uses reversible Karatsuba squaring.
    """
    in_piece_count = ceil_power_of_2(int(math.ceil(len(input) / piece_size)))
    input = input.padded(in_piece_count*piece_size - len(input))

    # Prepare padded input chunks.
    input_pieces_buf = []
    for j in range(in_piece_count):
        k = j * piece_size
        folds = popcnt((in_piece_count - 1) ^ j)
        input_pieces_buf.append(input[k:k+piece_size].padded(folds))

    # Prepare padded workspace chunks.
    work_piece_size = piece_size * 2 + popcnt(in_piece_count-1) * 4
    runs = int(math.ceil(work_piece_size / piece_size))
    work_piece_size = runs * piece_size
    work_regs = [IntBuf.zero(work_piece_size) for _ in range(in_piece_count*2)]

    # Add into workspaces, merge into output, then uncompute workspace.
    _add_square_into_pieces(input_pieces_buf, work_regs, sign=+1)
    for i in range(0, work_piece_size, piece_size):
        output[i:] += IntBuf.concat(w[i:i+piece_size] for w in work_regs)
    _add_square_into_pieces(input_pieces_buf, work_regs, sign=-1)


def _add_square_into_pieces(input_pieces: List[IntBuf],
                            output_pieces: List[IntBuf],
                            sign: int):
    """Inline Karatsuba squaring over the pieces.

    Note that the pieces must be large enough to hold intermediate results.
    """

    assert len(output_pieces) == len(input_pieces) * 2
    assert sign in [-1, +1]
    if not input_pieces:
        return
    if len(input_pieces) == 1:
        output_pieces[0] += int(input_pieces[0])**2 * sign
        return
    h = len(input_pieces) >> 1

    # Input is logically split into two halves (a, b) such that
    #   a + 2**(wh) * b equals the input.

    # -----------------------------------
    # Perform
    #     out += a**2 * (1-2**(wh))
    #     out -= b**2 * 2**(wh) * (1-2**(wh))
    # -----------------------------------
    # Temporarily inverse-multiply the output by 1-2**(wh), so that the following
    # two squared additions are scaled by 1-2**(wh).
    for i in range(h, len(output_pieces)):
        output_pieces[i] += output_pieces[i - h]
    # Recursive squared addition for a.
    _add_square_into_pieces(
        input_pieces=input_pieces[:h],
        output_pieces=output_pieces[:2*h],
        sign=sign)
    # Recursive squared subtraction for b.
    _add_square_into_pieces(
        input_pieces=input_pieces[h:2*h],
        output_pieces=output_pieces[h:3*h],
        sign=-sign)
    # Multiply output by 1-2**(wh), completing the scaling of the previous
    # two squared additions.
    for i in range(h, len(output_pieces))[::-1]:
        output_pieces[i] -= output_pieces[i - h]

    # -------------------------------
    # Perform
    #     out += (a+b)**2 * 2**(wh)
    # -------------------------------
    # Temporarily store a+b over a.
    for i in range(h):
        input_pieces[i] += input_pieces[i + h]
    # Recursive squared addition for a+b.
    _add_square_into_pieces(
        input_pieces=input_pieces[:h],
        output_pieces=output_pieces[h:3*h],
        sign=sign)
    # Restore a.
    for i in range(h):
        input_pieces[i] -= input_pieces[i + h]
