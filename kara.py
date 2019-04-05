import math

from .int_buffer import IntBuf, RawIntBuffer, RawWindowBuffer, RawConcatBuffer


def ceil_power_of_2(n: int) -> int:
    if n <= 1:
        return 1
    return 1 << int(math.ceil(math.log2(n)))


def add_square_into(val: IntBuf,
                    out: IntBuf,
                    pos: bool = True,
                    n: int = None):
    add_raw_square_into(val, out, pos, n)
    add_rem_square_into(val, out, pos, n)


def add_raw_square_into(val: IntBuf,
                    out: IntBuf,
                    pos: bool = True,
                    n: int = None):
    if n is None:
        n = ceil_power_of_2(len(val))
    n >>= 1
    if n <= 2:
        out += (+1 if pos else -1) * int(val)**2
        return

    p = 4
    m = n
    while m >= p:
        times_mul_inverse_1k1(m, out)
        m >>= 1

    seq = [True]
    for i in range(0, n * 2, p):
        if i//p >= len(seq):
            seq = seq + [not e for e in seq]
        sign = +1 if seq[i//p] == pos else -1
        out[i:] += int(val[i:i+p])**2 * sign

    m = n
    while m >= p:
        out[m:] -= out
        m >>= 1


def add_rem_square_into(val: IntBuf,
                    out: IntBuf,
                    pos: bool = True,
                    n: int = None):
    if n is None:
        n = ceil_power_of_2(len(val))
    n >>= 1
    if n <= 2:
        return

    a = val[:n]
    b = val[n:]
    times_mul_inverse_1k1(n, out)
    add_rem_square_into(a, out, pos, n)
    add_rem_square_into(b, out[n:], not pos)
    out[n:] -= out[:]

    c = a.padded(1)
    c += b
    add_square_into(a, out[n:], pos, n)
    if c[-1]:
        m = len(c)
        out[n+m:] += int(a) * (+1 if pos else -1)
        out[n+2*m-2:] += +1 if pos else -1
    c -= b


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
