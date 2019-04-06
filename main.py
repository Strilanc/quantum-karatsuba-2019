import math

from int_buffer import IntBuf
from kara2 import add_square_into_mut, SquareStatsTracker
import matplotlib.pyplot as plt


def main():
    xs = []
    ys1 = []
    ys2 = []
    ys3 = []
    for p in range(100):
        n = int(1.1**p)
        if n >= 10000:
            break
        out = IntBuf.zero(2*n)
        inp = IntBuf.zero(n)
        stats = SquareStatsTracker()
        add_square_into_mut(inp, out, stats=stats)
        xs.append(n)
        ys1.append(stats.word_additions)
        ys2.append(stats.word_squares)
        ys3.append(stats.raw)
        print(n, stats.word_additions, stats.word_squares)

    # xs0 = []
    # ys0 = []
    # for ps in range(5, 200):
    #     stats = SquareStatsTracker()
    #     for n in [1000, 1051, 1100, 1400]:
    #         out = IntBuf.zero(2*n)
    #         inp = IntBuf.zero(n)
    #         add_square_into_mut(inp, out, stats=stats, piece_size=ps)
    #     xs0.append(ps)
    #     ys0.append(stats.raw)
    #     print(ps, stats.raw)
    # plt.plot(xs0, ys0)


    plt.xscale('log')
    plt.yscale('log')
    ys4 = [n**math.log2(3) for n in xs]
    ys5 = [n**2/2 for n in xs]
    # plt.plot(xs, ys1)
    # plt.plot(xs, ys2)
    plt.plot(xs, ys3)
    plt.plot(xs, ys4)
    plt.plot(xs, ys5)
    plt.show()


if __name__ == '__main__':
    main()
