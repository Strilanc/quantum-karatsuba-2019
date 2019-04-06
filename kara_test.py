import random

from .int_buffer import IntBuf
from .kara import (
    add_square_into, mask_iter, set_bit_vals, power_of_two_ness, ceil_lg2, split_into_pieces, fuse_pieces, add_into_pieces, add_square_into_pieces, generate_blocks, MutableInt,
    add_square_into_pieces_using_generated_blocks,
)


def test_add_square_into_small():
    acc = IntBuf.zero(20)
    inp = IntBuf.zero(20)
    t = 0
    for i in range(100):
        inp[:] = i
        add_square_into(inp, acc)
        t += i*i
        t %= 2**len(acc)
        assert int(acc) == t


def test_add_square_into_large():
    for n in [16, 32, 64, 128]:
        x = random.randint(0, 2**n - 1)
        y = random.randint(0, 2**n - 1)
        val = IntBuf.zero(n)
        out = IntBuf.zero(n)
        val[:] = x
        out[:] = y
        add_square_into(val, out)
        assert out == (y + x**2) % 2**n


def test_known_failures():
    n = 128
    x = 309859417082872587300573064293124092539
    y = 107908178516259704616406393704185964006
    val = IntBuf.zero(n)
    out = IntBuf.zero(n)
    val[:] = x
    out[:] = y
    add_square_into(val, out)
    assert out == (y + x**2) % 2**n

    # xx = []
    # add_square_into(val, out, results=xx)
    # def f(r):
    #     return bin(r)[2:-2].rjust(10, '_').replace('0', '_')
    # for factors, merges, position in sorted(xx, key=lambda e: (e[1], e[0])):
    #     print('f' + f(factors), 'm' + f(merges), 'p' + f(position))
    # assert False


def test_add_square_into_pieces_using_generated_blocks():
    piece_size = 16
    piece_count = 256
    # random.seed(4)
    r1 = random.randint(0, ~(-1 << (piece_count*piece_size)))
    r2 = random.randint(0, ~(-1 << (piece_count*piece_size*2)))
    p1 = split_into_pieces(r1, piece_size=piece_size, piece_count=piece_count)
    p2 = split_into_pieces(r2, piece_size=piece_size, piece_count=piece_count*2)
    q1 = list(p1)
    # add_square_into_pieces(input_pieces=p1, output_pieces=p2)
    add_square_into_pieces_using_generated_blocks(input_pieces=p1, output_pieces=p2)
    assert q1 == p1
    assert fuse_pieces(p1, piece_size) == r1
    expected = r1**2 + r2
    actual = fuse_pieces(p2, piece_size)
    assert actual == expected, (actual, expected, r2, '+', r1**2)


# def test_piecewise_addition():
#     r1 = random.randint(0, ~(-1 << 100))
#     r2 = random.randint(0, ~(-1 << 100))
#     p1 = split_into_pieces(r1, 10, 10)
#     p2 = split_into_pieces(r2, 10, 10)
#     add_into_pieces(input_pieces=p1, output_pieces=p2)
#     assert fuse_pieces(p1, 10) == r1
#     assert fuse_pieces(p2, 10) == r1 + r2
#
#
# def test_piecewise_square_addition():
#     piece_size = 16
#     piece_count = 16
#     r1 = random.randint(0, ~(-1 << (piece_count*piece_size)))
#     r2 = random.randint(0, ~(-1 << (piece_count*piece_size*2)))
#     p1 = split_into_pieces(r1, piece_size=piece_size, piece_count=piece_count)
#     p2 = split_into_pieces(r2, piece_size=piece_size, piece_count=piece_count*2)
#     q1 = list(p1)
#     add_square_into_pieces(input_pieces=p1, output_pieces=p2)
#     assert q1 == p1
#     assert fuse_pieces(p1, piece_size) == r1
#     expected = r1**2 + r2
#     actual = fuse_pieces(p2, piece_size)
#     assert actual == expected, (actual, expected, r2, '+', r1**2)
#
#
# def test_set_bit_vals():
#     assert set_bit_vals(0) == []
#     assert set_bit_vals(1) == [1]
#     assert set_bit_vals(2) == [2]
#     assert set_bit_vals(3) == [1, 2]
#     assert set_bit_vals(4) == [4]
#     assert set_bit_vals(5) == [1, 4]
#     assert set_bit_vals(6) == [2, 4]
#     assert set_bit_vals(7) == [1, 2, 4]
#     assert set_bit_vals(8) == [8]
#     assert set_bit_vals(9) == [1, 8]
#
#
# def test_mask_iter():
#     assert mask_iter(0) == [0]
#     assert mask_iter(1) == [0, 1]
#     assert mask_iter(2) == [0, 2]
#     assert mask_iter(3) == [0, 1, 2, 3]
#     assert mask_iter(4) == [0, 4]
#     assert mask_iter(5) == [0, 1, 4, 5]
#
#
# def test_power_of_two_ness():
#     assert power_of_two_ness(1) == 1
#     assert power_of_two_ness(2) == 2
#     assert power_of_two_ness(3) == 1
#     assert power_of_two_ness(4) == 4
#     assert power_of_two_ness(5) == 1
#     assert power_of_two_ness(6) == 2
#     assert power_of_two_ness(7) == 1
#     assert power_of_two_ness(8) == 8
#     assert power_of_two_ness(9) == 1
#
#
# def test_ceil_lg2():
#     assert ceil_lg2(1) == 0
#     assert ceil_lg2(2) == 1
#     assert ceil_lg2(3) == 2
#     assert ceil_lg2(4) == 2
#     assert ceil_lg2(5) == 3
#     assert ceil_lg2(6) == 3
#     assert ceil_lg2(7) == 3
#     assert ceil_lg2(8) == 3
#     assert ceil_lg2(9) == 4
#
#
# def test_generate_blocks():
#     n = 128
#     expected = []
#     add_square_into_pieces(input_pieces=[MutableInt(0) for _ in range(n)],
#                            output_pieces=[MutableInt(0) for _ in range(2*n)],
#                            record=expected)
#     actual = generate_blocks(n)
#     assert len(expected) == len(set(expected))
#     assert len(actual) == len(set(actual))
#     assert len(actual) == len(expected)
#     # exp1 = sorted(exp, key=lambda e: (e[0], e[1], e[2]))
#     # actual1 = sorted(actual, key=lambda e: (e[0], e[1], e[2]))
#     # for e, f in zip(exp1, actual1):
#     #     if e != f:
#     #         print(bin(e[0])[2:].rjust(6, '0'), bin(e[1])[2:].rjust(6, '0'), '-' if e[2]==-1 else '+', bin(f[0])[2:].rjust(6, '0'), bin(f[1])[2:].rjust(6, '0'), f[2])
#     # for e in set(exp) - set(actual):
#     #     print("MISSING", e)
#     # for e in set(actual) - set(exp):
#     #     print("EXTRA", e)
#     assert set(actual) == set(expected)
