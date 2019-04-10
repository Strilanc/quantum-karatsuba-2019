import random
from typing import Optional

from int_buffer import IntBuf
from kara_mul import add_product_into


def assert_case(*, n_in1: int, v_in1: int, n_in2: int, v_in2: int, n_out: Optional[int] = None, v_out: int = 0, **kwargs):
    # Generate Q# case.
    # print("""
    #     AssertProductCase(
    #         {},
    #         {},
    #         BoolsToBigInt([{},false]),
    #         BoolsToBigInt([{},false]),
    #         {});""".format(
    #     n_in1,
    #     n_in2,
    #     ','.join('true' if e == '1' else 'false' for e in bin(v_in1)[2:]),
    #     ','.join('true' if e == '1' else 'false' for e in bin(v_in2)[2:]),
    #     kwargs.get('piece_size', 32)))

    if n_out is None:
        n_out = max(n_in1, n_in2) * 2
    assert 0 <= v_in1 < 1 << n_in1
    assert 0 <= v_in2 < 1 << n_in2
    assert 0 <= v_out < 1 << n_out
    b_in1 = IntBuf.zero(n_in1)
    b_in2 = IntBuf.zero(n_in2)
    b_out = IntBuf.zero(n_out)
    b_in1[:] = v_in1
    b_in2[:] = v_in2
    b_out[:] = v_out
    add_product_into(b_in1, b_in2, b_out, **kwargs)

    expected_out = (v_out + v_in1*v_in2) % 2**n_out
    if b_in1 != v_in1 or b_in2 != v_in2 or b_out != expected_out:
        raise AssertionError("""Case failed.
    assert_case(n_in1={0}, n_in2={1}, n_out={2}, v_in1={3}, v_in2={4}, v_out={5}{8})
    n_in1={0}
    n_in2={1}
    n_out={2}
    v_in1={3}
    v_in2={4}
    v_out={5}
    Expected result={6}
    Actual result={7}""".format(
                n_in1,
                n_in2,
                n_out,
                v_in1,
                v_in2,
                v_out,
                expected_out,
                int(b_out),
                ''.join(', {}={!r}'.format(k, v) for k, v in kwargs.items())
            ))


def test_fuzz():
    for _ in range(20):
        n1 = random.randint(0, 256)
        n2 = random.randint(0, 256)
        n3 = random.randint(0, 256)
        v1 = random.randint(0, 2**n1 - 1)
        v2 = random.randint(0, 2**n2 - 1)
        v3 = random.randint(0, 2**n3 - 1)
        assert_case(n_in1=n1, n_in2=n2, n_out=n3, v_in1=v1, v_in2=v2, v_out=v3)


def test_individual_bits():
    for n1 in range(6):
        for n2 in range(n1, 6):
            for b1 in range(n1):
                for b2 in range(n2):
                    assert_case(n_in1=n1, n_in2=n2, v_in1=1<<b1, v_in2=1<<b2, piece_size=1)


def test_small_cases():
    for n1 in range(3):
        for n2 in range(3):
            for v1 in range(1 << n1):
                for v2 in range(1 << n2):
                    assert_case(n_in1=n1, n_in2=n2, v_in1=v1, v_in2=v2, piece_size=1)


def test_piece_sizes():
    for n in range(1, 10):
        assert_case(n_in1=32, n_in2=32, v_in1=1620786985, v_in2=623629819, piece_size=n)


def test_known_historical_failures():
    assert_case(n_in1=24,
                n_in2=66,
                n_out=140,
                v_in1=1779106,
                v_in2=67497413763205155466,
                v_out=1191139883759256012588948494142022305808990,
                piece_size=4)
