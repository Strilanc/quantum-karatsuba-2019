import random

from .int_buffer import IntBuf
from .kara import add_square_into


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
    n = 200
    x = random.randint(0, 2**n - 1)
    y = random.randint(0, 2**n - 1)
    val = IntBuf.zero(n)
    out = IntBuf.zero(n)
    val[:] = x
    out[:] = y
    add_square_into(val, out)
    assert out == (y + x**2) % 2**n
