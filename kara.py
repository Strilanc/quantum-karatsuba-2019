from .int_buffer import IntBuf


def add_square_into(val: IntBuf, out: IntBuf, pos: bool = True, pad: int = 0, pad_fill: int = 0):
    n = (len(val) - pad) >> 1
    if n <= 2:
        if pos:
            out += int(val)**2
        else:
            out -= int(val)**2
        return

    a = val[:n]
    b = val[n:]
    out *= modinv(2**n - 1, 1 << len(out))
    add_square_into(a, out, not pos, 0, pad_fill)
    add_square_into(b, out[n:], pos, pad, pad_fill)
    out *= -1
    out[n:] -= out[:]
    assert len(b) >= len(a)
    pad_fill += 1
    if pad_fill >= 1 << pad:
        pad += 1
        b = b.padded(1)
    b += a
    add_square_into(b, out[n:], pos, pad, pad_fill)
    b -= a


def egcd(a, b):
    if a == 0:
        return (b, 0, 1)
    else:
        g, y, x = egcd(b % a, a)
        return (g, x - (b // a) * y, y)

def modinv(a, m):
    g, x, y = egcd(a, m)
    if g != 1:
        raise Exception('modular inverse does not exist')
    else:
        return x % m
