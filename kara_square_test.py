import random
from typing import Optional

from int_buffer import IntBuf
from kara_square import add_square_into


def assert_case(*, n_in: int, v_in: int, n_out: Optional[int] = None, v_out: int = 0, **kwargs):
    # Generate Q# case.
    # print("""
    #     AssertSquareCase(
    #         {},
    #         BoolsToBigInt([{},false]),
    #         {});""".format(
    #     n_in,
    #     ','.join('true' if e == '1' else 'false' for e in bin(v_in)[2:]),
    #     kwargs.get('piece_size', 32)))

    if n_out is None:
        n_out = n_in * 2
    assert 0 <= v_in < 1 << n_in
    assert 0 <= v_out < 1 << n_out
    b_in = IntBuf.zero(n_in)
    b_out = IntBuf.zero(n_out)
    b_in[:] = v_in
    b_out[:] = v_out
    add_square_into(b_in, b_out, **kwargs)

    expected_out = (v_out + v_in**2) % 2**n_out
    if b_in != v_in or b_out != expected_out:
        raise AssertionError("""Case failed.
    assert_case(n_in={0}, n_out={1}, v_in={2}, v_out={3}{6})
    n_in={0}
    n_out={1}
    v_in={2}
    v_out={3}
    Expected result={4}
    Actual result={5}""".format(
                n_in,
                n_out,
                v_in,
                v_out,
                expected_out,
                int(b_out),
                ''.join(', {}={!r}'.format(k, v) for k, v in kwargs.items())
            ))


def test_fuzz():
    for _ in range(20):
        n1 = random.randint(0, 256)
        n2 = random.randint(0, 256)
        v1 = random.randint(0, 2**n1 - 1)
        v2 = random.randint(0, 2**n2 - 1)
        assert_case(n_in=n1, n_out=n2, v_in=v1, v_out=v2)


def test_individual_bits():
    for n_in in range(10):
        for b_in in range(n_in):
            assert_case(n_in=n_in, n_out=20, v_in=1<<b_in, piece_size=1)


def test_piece_sizes():
    for p in range(1, 10):
        assert_case(n_in=32, v_in=1620786985, piece_size=p)


def test_small_cases():
    for n_in in range(4):
        for v_in in range(1 << n_in):
            assert_case(n_in=n_in, v_in=v_in, piece_size=1)


def test_known_historical_failures():
    assert_case(n_in=8,
                v_in=0b11111111,
                piece_size=4)
    assert_case(n_in=207,
                n_out=81,
                v_in=99309357899598905347205841219742550058564968316992108090982783,
                v_out=2417272450293295125057780)
    assert_case(n_in=128,
                n_out=128,
                v_in=309859417082872587300573064293124092539,
                v_out=107908178516259704616406393704185964006)
    assert_case(n_in=66,
                n_out=140,
                v_in=67497413763205155466,
                v_out=1191139883759256012588948494142022305808990)
