import math

from .int_buffer import IntBuf


def add_square_into(val: IntBuf,
                    out: IntBuf,
                    pos: bool = True,
                    pad: int = 0,
                    pad_fill: int = 0):
    n = (len(val) - pad) >> 1
    if n <= 2:
        if pos:
            out += int(val)**2
        else:
            out -= int(val)**2
        return

    a = val[:n]
    b = val[n:]
    times_mul_inverse_1k1(n, out)
    add_square_into(a, out, pos, 0, pad_fill)
    add_square_into(b, out[n:], not pos, pad, pad_fill)
    out[n:] -= out[:]
    assert len(b) >= len(a)
    pad_fill += 1
    if pad_fill >= 1 << pad:
        pad += 1
        b = b.padded(1)
    b += a
    add_square_into(b, out[n:], pos, pad, pad_fill)
    b -= a
    out[n:] -= out[:]
    assert len(b) >= len(a)
    pad_fill += 1
    if pad_fill >= 1 << pad:
        pad += 1
        b = b.padded(1)
    b += a
    add_square_into(b, out[n:], pos, pad, pad_fill)
    b -= a


def times_mul_inverse_1k1(n: int, out: IntBuf):
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
