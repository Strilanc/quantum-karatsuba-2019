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

    operation MeasureBigInteger(qs: LittleEndian) : BigInt {
        mutable result = ToBigInt(0);
        mutable i = 0;
        for (q in qs!) {
            if (Measure([PauliZ], [q]) == One) {
                set result = result + (ToBigInt(1) <<< i);
            }
            set i = i + 1;
        }
        return result;
    }

    operation MeasureSignedBigInteger(qs: LittleEndian) : BigInt {
        mutable result = MeasureBigInteger(qs);
        if (result >= ToBigInt(1) <<< (Length(qs!) - 1)) {
            set result = result - (ToBigInt(1) <<< Length(qs!));
        }
        return result;
    }

    operation MeasureResetBigInteger(qs: LittleEndian) : BigInt {
        mutable result = ToBigInt(0);
        mutable i = 0;
        for (q in qs!) {
            if (Measure([PauliZ], [q]) == One) {
                set result = result + (ToBigInt(1) <<< i);
                X(q);
            }
            set i = i + 1;
        }
        return result;
    }
}
