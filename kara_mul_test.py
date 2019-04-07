import random

from int_buffer import IntBuf
from kara_mul import add_mul_into_mut


def test_add_mul_into_small():
    acc = IntBuf.zero(20)
    inp1 = IntBuf.zero(20)
    inp2 = IntBuf.zero(20)
    t = 0
    for i in range(50):
        for j in range(50):
            inp1[:] = i
            inp2[:] = j
            add_mul_into_mut(inp1, inp2, acc)
            t += i*j
            t %= 2**len(acc)
            assert int(acc) == t
            assert int(inp1) == i
            assert int(inp2) == j


def test_add_mul_into_large():
    for n in [16, 32, 64, 128, 256, 512, 1024]:
        x = random.randint(0, 2**n - 1)
        y = random.randint(0, 2**n - 1)
        z = random.randint(0, 2**n - 1)
        val1 = IntBuf.zero(n)
        val2 = IntBuf.zero(n)
        out = IntBuf.zero(n)
        val1[:] = x
        val2[:] = y
        out[:] = z
        add_mul_into_mut(val1, val2, out)
        assert int(val1) == x
        assert int(val2) == y
        assert out == (z + x*y) % 2**n
