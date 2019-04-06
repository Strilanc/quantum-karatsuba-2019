import math
import random
from typing import Iterable, Sequence, List, Tuple, Any

from .int_buffer import IntBuf, RawIntBuffer, RawWindowBuffer, RawConcatBuffer


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


def add_square_into(val: IntBuf,
                    out: IntBuf,
                    pos: bool = True,
                    n: int = None,
                    factors: int = 0,
                    merges: int = 0,
                    position: int = 0,
                    results = None):
    if n is None:
        n = ceil_power_of_2(len(val))
    n >>= 1
    if n <= 2:
        if results is not None:
            results.append((factors, merges, position))
        out += (+1 if pos else -1) * int(val)**2
        return

    a = val[:n]
    b = val[n:]
    times_mul_inverse_1k1(n, out)
    add_square_into(a, out, pos, n, factors + n, merges, position, results)
    add_square_into(b, out[n:], not pos, n, factors + n, merges, position + n, results)
    out[n:] -= out[:]

    c = a.padded(1)
    c += b
    add_square_into(a, out[n:], pos, n, factors, merges + n, position + n, results)
    if c[-1]:
        m = len(c)
        out[n + m:] += int(a) * (+1 if pos else -1)
        out[n + 2 * m - 2:] += +1 if pos else -1
    c -= b


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


def fuse_pieces(pieces: List[MutableInt], piece_size: int) -> int:
    result = 0
    for i, p in enumerate(pieces):
        result += p.val << (i * piece_size)
    return result


def add_into_pieces(input_pieces: List[MutableInt],
                    output_pieces: List[MutableInt],
                    factor: int = 1):
    assert len(input_pieces) == len(output_pieces)
    for i in range(len(input_pieces)):
        output_pieces[i] += input_pieces[i].val * factor


def generate_blocks(n: int):
    result = []
    for s in range(n):
        for i in range(n):
            if i | s == n - 1:
                result.append((i, s, -1 if hamming_seq(i & s) else +1))
    return result


def add_square_into_pieces(input_pieces: List[MutableInt],
                           output_pieces: List[MutableInt],
                           pos: bool = True,
                           i1: int = 0,
                           i2: int = None,
                           o1: int = 0,
                           o2: int = None,
                           s1: int = 0,
                           s2: int = 0,
                           record: List[Any] = None):
    if i2 is None:
        i2 = len(input_pieces)
    if o2 is None:
        o2 = len(output_pieces)
    assert len(input_pieces) * 2 == len(output_pieces)
    if len(input_pieces) == 1:
        output_pieces[0] += input_pieces[0].val**2 * (+1 if pos else -1)
        # print('out.append((0b{}, 0b{}, {}1))'.format(
        #     bin(i1)[2:].rjust(6, '0'),
        #     # bin(i2)[2:].rjust(6, '_'),
        #     # bin(o1)[2:].rjust(6, '_'),
        #     # bin(o2)[2:].rjust(6, '_'),
        #     bin(s1)[2:].rjust(6, '0'),
        #     # bin(s2)[2:].rjust(6, '_'),
        #     '+' if pos else '-'))
        if record is not None:
            record.append((i1, s1, +1 if pos else -1))
        assert i2 == i1 + 1, (i2, i1)
        assert s1 & s2 == 0
        assert pos == (not hamming_seq(i1 & s1))
        return
    h = len(input_pieces) >> 1
    assert not s1 & h
    assert i2 - i1 == h*2, (i2, i1, h)
    assert o2 - o1 == (i2 - i1)*2
    assert o1 == i1
    assert i2 == i1 + 2*h
    assert o2 == o1 + 4*h

    for i in range(h, len(output_pieces)):
        output_pieces[i] += output_pieces[i - h]
    add_square_into_pieces(input_pieces=input_pieces[:h],
                           output_pieces=output_pieces[:2*h],
                           pos=pos,
                           i1=i1,
                           i2=i1 + h,
                           o1=o1,
                           o2=o1 + 2*h,
                           s1=s1 | h,
                           s2=s2,
                           record=record)
    add_square_into_pieces(input_pieces=input_pieces[h:],
                           output_pieces=output_pieces[h:3*h],
                           pos=not pos,
                           i1=i1 + h,
                           i2=i2,
                           o1=o1 + h,
                           o2=o1 + 3*h,
                           s1=s1 | h,
                           s2=s2,
                           record=record)
    for i in range(h, len(output_pieces))[::-1]:
        output_pieces[i] -= output_pieces[i - h]

    add_into_pieces(input_pieces[:h], input_pieces[h:])
    add_square_into_pieces(input_pieces=input_pieces[h:],
                           output_pieces=output_pieces[h:3*h],
                           pos=pos,
                           i1=i1 + h,
                           i2=i2,
                           o1=o1 + h,
                           o2=o1 + 3*h,
                           s1=s1,
                           s2=s2 | h,
                           record=record)
    add_into_pieces(input_pieces[:h], input_pieces[h:], factor=-1)


def add_square_into_pieces_using_generated_blocks(input_pieces: List[MutableInt],
                           output_pieces: List[MutableInt]):

    print()
    f_steps = []
    g_steps = []
    def f(step):
        print("MIX", step, f_locks)
        f_steps.append((step, f_mixed))
        for i in range(step, 2 * n):
            # if (i & ~n) & f_mixed == (i & ~n) ^ (mask & ~f_mixed):
                output_pieces[i] += output_pieces[i - step]
    def fi(step):
        print("---", step, f_locks)
        assert f_steps.pop() == (step, f_mixed)
        for i in range(step, 2 * n)[::-1]:
            # if (i & ~n) & f_mixed == (i & ~n) ^ (mask & ~f_mixed):
            # if i & (f_mixed | n) == f_mixed | n:
                output_pieces[i] -= output_pieces[i - step]

    def g(step):
        # print("G", step, (locked_to_one))
        assert g_steps.pop() == (step, g_locked_to_one)
        for i in mask_iter(g_locked_to_one ^ mask):
            i ^= mask
            if i & step:
                input_pieces[i] -= input_pieces[i - step]
    def gi(step):
        # print("x", step, (locked_to_one))
        g_steps.append((step, g_locked_to_one))
        for i in mask_iter(g_locked_to_one ^ mask):
            i ^= mask
            if i & step:
                input_pieces[i] += input_pieces[i - step]

    n = len(input_pieces)
    assert n == ceil_power_of_2(n)
    mask = n - 1

    g_locked_to_one = 0
    g_locks = []
    for step in set_bit_vals(mask)[::-1]:
        gi(step)
        g_locks.append(step)
        g_locked_to_one |= step

    f_mixed = 0
    f_locks = []

    for mode in range(n):
        if mode:
            k = int(math.log2(power_of_two_ness(mode)))

            for i in range(k):
                step = 1 << i
                fi(step)
                f_mixed &= ~step
                assert f_locks.pop() == step

            step = 1 << k
            assert g_locks.pop() == step
            f_locks.append(step)
            g_locked_to_one &= ~step
            f_mixed |= step
            f(step)
            g(step)

            for i in range(k)[::-1]:
                step = 1 << i
                gi(step)
                g_locks.append(step)
                g_locked_to_one |= step

        assert g_locked_to_one == mode ^ mask, (g_locked_to_one, mode)
        assert f_mixed == mode
        print('ROUND', mode, len(mask_iter(mode)), bin(f_mixed)[2:].rjust(10, '0'), bin(g_locked_to_one)[2:].rjust(10, '0'))
        for i in mask_iter(mode):
            assert not i & g_locked_to_one
            i ^= mask
            assert i & f_mixed == i ^ (mask & ~f_mixed)
            sign = -1 if hamming_seq(i & mode) else +1
            output_pieces[i] += int(input_pieces[i])**2 * sign

    assert g_locked_to_one == 0
    v = 1
    while v < n:
        step = v
        fi(step)
        f_mixed &= ~step
        assert f_locks.pop() == step
        v <<= 1


# def add_square_into_pieces(input_pieces: List[int],
#                            output_pieces: List[int]):
#     if n is None:
#         n = ceil_power_of_2(len(val))
#     n >>= 1
#     if n <= 2:
#         if results is not None:
#             results.append((factors, merges, position))
#         out += (+1 if pos else -1) * int(val)**2
#         return
#
#     a = val[:n]
#     b = val[n:]
#     times_mul_inverse_1k1(n, out)
#     add_square_into(a, out, pos, n, factors + n, merges, position, results)
#     add_square_into(b, out[n:], not pos, n, factors + n, merges, position + n, results)
#     out[n:] -= out[:]
#
#     c = a.padded(1)
#     c += b
#     add_square_into(a, out[n:], pos, n, factors, merges + n, position + n, results)
#     if c[-1]:
#         m = len(c)
#         out[n + m:] += int(a) * (+1 if pos else -1)
#         out[n + 2 * m - 2:] += +1 if pos else -1
#     c -= b


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


def add_square_into_alt(val: IntBuf, out: IntBuf):
    n = ceil_power_of_2(max(len(val), len(out)))
    mask = (n - 1) >> 2
    s = ceil_lg2(mask)
    prev_m = 0

    p = 4
    v0 = int(val)
    in_pieces = [val[i:i+p].padded(10) for i in range(0, n, p)]
    out_pieces = [IntBuf.zero(2*p+10) for _ in range(0, n, p)]
    for k in out_pieces:
        k[:] = random.randint(0, 1 << 100)
    o0 = [int(o) for o in out_pieces]
    os = []

    xx = mask
    for b in range(s)[::-1]:
        v = 1 << b
        os.append([int(o) for o in out_pieces])
        for p in mask_iter(xx):
            if p + v < len(out_pieces):
                print(p+v, '<-', p, end=' ')
                out_pieces[p + v] -= out_pieces[p]
        print()
        xx ^= v

    for m in range(mask + 1):
        # Transition pieces
        if m:
            k = ceil_lg2(power_of_two_ness(m))
            for r in range(k):
                v = 1 << r
                os.append([int(o) for o in out_pieces])
                for p in mask_iter(prev_m ^ mask):
                    if p + v < len(out_pieces):
                        print(p + v, '<-', p, end=' ')
                        out_pieces[p + v] += out_pieces[p]
                print()
                for p in mask_iter(prev_m)[::-1]:
                    if p + v < len(in_pieces):
                        in_pieces[p + v] -= in_pieces[p]
                prev_m ^= v

            v = 1 << k
            prev_m ^= v
            for p in mask_iter(prev_m ^ mask)[::-1]:
                if p + v < len(out_pieces):
                    print(p, '+>', p+v, end=' ')
                    out_pieces[p + v] += out_pieces[p]
            print()
            print('APPEND', prev_m ^ mask, v, [int(o) for o in out_pieces])
            assert os.pop() == [int(o) for o in out_pieces]
            for p in mask_iter(prev_m):
                if p + v < len(in_pieces):
                    in_pieces[p + v] += in_pieces[p]

        # Perform squaring work.
        # for p in range(mask):
        #     if p == p | m:
        #         out_pieces[p] += int(in_pieces[p])**2

    # Unfuse.
    for b in range(s):
        v = 1 << b
        for p in mask_iter(prev_m)[::-1]:
            if p + v < len(in_pieces):
                in_pieces[p + v] -= in_pieces[p]
        prev_m ^= v

    assert v0 == int(val)
    assert o0 == [int(o) for o in out_pieces]


# def add_square_into(val: IntBuf,
#                     out: IntBuf,
#                     pos: bool = True,
#                     n: int = None):
#     if n is None:
#         n = ceil_power_of_2(len(val))
#     n >>= 1
#     if n <= 2:
#         out += (+1 if pos else -1) * int(val)**2
#         return
#
#     p = 4
#     m = n
#     while m >= p:
#         times_mul_inverse_1k1(m, out)
#         m >>= 1
#
#     rng = range(0, n * 2, p)
#     positives = [i for i in rng if hamming_seq(i) ^ pos]
#     negatives = [i for i in rng if not hamming_seq(i) ^ pos]
#     positives.append(n * 2)
#     negatives.append(n * 2)
#
#     out *= -1  # Need implicit sign extension to avoid this.
#     buf = IntBuf.zero(0)
#     for i, j in adjacent_pairs(negatives):
#         r = out[i:j].padded(max(1, 2*p - (j-i)))
#         r += int(val[i:i+p])**2
#         r += buf
#         buf = r[j-i:]
#     out[2*n:] += buf
#     out *= -1
#
#     buf = IntBuf.zero(0)
#     for i, j in adjacent_pairs(positives):
#         r = out[i:j].padded(max(1, 2*p - (j-i)))
#         r += int(val[i:i+p])**2
#         r += buf
#         buf = r[j-i:]
#     out[2*n:] += buf
#
#     m = n
#     while m >= p:
#         out[m:] -= out
#         m >>= 1
#
#     add_rem_square_into(val, out, pos, n)
#
#
# def add_rem_square_into(val: IntBuf,
#                     out: IntBuf,
#                     pos: bool,
#                     n: int):
#     if n <= 2:
#         return
#
#     a = val[:n]
#     b = val[n:]
#     times_mul_inverse_1k1(n, out)
#     add_rem_square_into(a, out, pos, n >> 1)
#     add_rem_square_into(b, out[n:], not pos, n >> 1)
#     out[n:] -= out[:]
#
#     c = a.padded(1)
#     c += b
#     add_square_into(a, out[n:], pos, n)
#     if c[-1]:
#         m = len(c)
#         out[n+m:] += int(a) * (+1 if pos else -1)
#         out[n+2*m-2:] += +1 if pos else -1
#     c -= b


def times_mul_inverse_1k1(n: int, out: IntBuf):
    if not len(out):
        return
    p = int(math.ceil(math.log(len(out) / n)))
    pieces = []
    for i in range(0, len(out), n):
        pieces.append(out[i:i+n])

    buf = IntBuf.zero(0)
    for i in range(1, len(pieces)):
        r = pieces[i].padded(p)
        r += buf
        r += pieces[i - 1]
        buf = r[n:]


# def times_mul_inverse_1k1(pieces: List[int], reduction_mask: int, target_bit: int):
#     for p in range(len(pieces)):
#         if reduction_mask & p != reduction_mask:
#             continue
#         pieces[i + (1 << target_bit)]
#     if not len(out):
#         return
#     p = int(math.ceil(math.log(len(out) / n)))
#     pieces = []
#     for i in range(0, len(out), n):
#         pieces.append(out[i:i+n])
#
#     buf = IntBuf.zero(0)
#     for i in range(1, len(pieces)):
#         r = pieces[i].padded(p)
#         r += buf
#         r += pieces[i - 1]
#         buf = r[n:]
