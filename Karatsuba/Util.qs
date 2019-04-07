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

    function CeilMultiple(numerator: Int, multiple: Int) : Int {
        return ((numerator + multiple - 1) / multiple) * multiple;
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

    function CeilPowerOf2(n: Int) : Int {
        return 1 <<< CeilLg2(n);
    }

    function FloorLg2(n: Int) : Int {
        return FloorBigLg2(ToBigInt(n));
    }

    operation MeasureBigInt(qs: LittleEndian) : BigInt {
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

    operation MeasureSignedBigInt(qs: LittleEndian) : BigInt {
        mutable result = MeasureBigInt(qs);
        if (result >= ToBigInt(1) <<< (Length(qs!) - 1)) {
            set result = result - (ToBigInt(1) <<< Length(qs!));
        }
        return result;
    }

    operation MeasureResetBigInt(qs: LittleEndian) : BigInt {
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
