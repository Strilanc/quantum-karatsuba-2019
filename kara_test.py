import random

from .int_buffer import IntBuf
from .kara import add_square_into_mut, SquareStatsTracker


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
        assert int(inp) == i


def test_add_square_into_large():
    for n in [16, 32, 64, 128, 256, 512, 1024]:
        x = random.randint(0, 2**n - 1)
        y = random.randint(0, 2**n - 1)
        val = IntBuf.zero(n)
        out = IntBuf.zero(n)
        val[:] = x
        out[:] = y
        add_square_into_mut(val, out)
        assert out == (y + x**2) % 2**n
        assert int(val) == x


def test_known_failures():
    n = 128
    x = 309859417082872587300573064293124092539
    y = 107908178516259704616406393704185964006
    val = IntBuf.zero(n)
    out = IntBuf.zero(n)
    val[:] = x
    out[:] = y
    add_square_into_mut(val, out)
    assert out == (y + x**2) % 2**n
    assert int(val) == x
