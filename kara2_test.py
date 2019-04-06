import random

from .int_buffer import IntBuf
from .kara import (
    add_square_into, mask_iter, set_bit_vals, power_of_two_ness, ceil_lg2, split_into_pieces, fuse_pieces, add_into_pieces, add_square_into_pieces, generate_blocks, MutableInt,
    add_square_into_pieces_using_generated_blocks,
)
from .kara2 import add_square_into_mut


def test_add_square_into_small():
    acc = IntBuf.zero(20)
    inp = IntBuf.zero(20)
    t = 0
    for i in range(100):
        inp[:] = i
        add_square_into_mut(inp, acc)
        t += i*i
        t %= 2**len(acc)
        assert int(acc) == t
#
#
# def test_add_square_into_large():
#     for n in [16, 32, 64, 128]:
#         x = random.randint(0, 2**n - 1)
#         y = random.randint(0, 2**n - 1)
#         val = IntBuf.zero(n)
#         out = IntBuf.zero(n)
#         val[:] = x
#         out[:] = y
#         add_square_into(val, out)
#         assert out == (y + x**2) % 2**n
#
#
# def test_known_failures():
#     n = 128
#     x = 309859417082872587300573064293124092539
#     y = 107908178516259704616406393704185964006
#     val = IntBuf.zero(n)
#     out = IntBuf.zero(n)
#     val[:] = x
#     out[:] = y
#     add_square_into(val, out)
#     assert out == (y + x**2) % 2**n
#
#     # xx = []
#     # add_square_into(val, out, results=xx)
#     # def f(r):
#     #     return bin(r)[2:-2].rjust(10, '_').replace('0', '_')
#     # for factors, merges, position in sorted(xx, key=lambda e: (e[1], e[0])):
#     #     print('f' + f(factors), 'm' + f(merges), 'p' + f(position))
#     # assert False
#
#
# def test_add_square_into_pieces():
#     piece_size = 16
#     piece_count = 256
#     # random.seed(4)
#     r1 = random.randint(0, ~(-1 << (piece_count*piece_size)))
#     r2 = random.randint(0, ~(-1 << (piece_count*piece_size*2)))
#     p1 = split_into_pieces(r1, piece_size=piece_size, piece_count=piece_count)
#     p2 = split_into_pieces(r2, piece_size=piece_size, piece_count=piece_count*2)
#     q1 = list(p1)
#     # add_square_into_pieces(input_pieces=p1, output_pieces=p2)
#     test_add_square_into_pieces(input_pieces=p1, output_pieces=p2)
#     assert q1 == p1
#     assert fuse_pieces(p1, piece_size) == r1
#     expected = r1**2 + r2
#     actual = fuse_pieces(p2, piece_size)
#     assert actual == expected, (actual, expected, r2, '+', r1**2)
