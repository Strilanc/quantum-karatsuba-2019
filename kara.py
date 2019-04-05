from .int_buffer import IntBuf


def add_square_into(val: IntBuf, out: IntBuf, pos: bool = True):
    n = len(val) >> 1
    if n <= 2:
        if pos:
            out += int(val)**2
        else:
            out -= int(val)**2
        return

    a = val[:n]
    b = val[n:]
    out *= modinv(2**n - 1, 1 << len(out))
    add_square_into(a, out, not pos)
    add_square_into(b, out[n:], pos)
    out *= 2**n - 1
    assert len(b) >= len(a)
    c = b.padded(1)
    c += a
    add_square_into(c, out[n:], pos)
    c -= a


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
