namespace Karatsuba {
    open Microsoft.Quantum.Extensions.Bitwise;
    open Microsoft.Quantum.Extensions.Convert;
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;

    function FloorBigLg2(n: BigInt) : Int {
        if (n <= ToBigInt(1)) {
            return 0;
        }
        let bools = BigIntToBools(n);
        mutable m = Length(bools) - 1;
        for (i in 0..7) {
            if (not bools[m]) {
                set m = m - 1;
            }
        }
        return m;
    }

    function CeilBigLg2(n: BigInt) : Int {
        if (n <= ToBigInt(1)) {
            return 0;
        }
        return FloorBigLg2(n - ToBigInt(1)) + 1;
    }

    function CeilLg2(n: Int) : Int {
        return CeilBigLg2(ToBigInt(n));
    }

    function FloorLg2(n: Int) : Int {
        return FloorBigLg2(ToBigInt(n));
    }
}
