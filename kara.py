import math

from .int_buffer import IntBuf


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

    a = val[:n]
    b = val[n:]
    times_mul_inverse_1k1(n, out)
    add_raw_square_into(a, out, pos, n)
    add_raw_square_into(b, out[n:], not pos)
    out[n:] -= out[:]


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
