namespace Tests {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Diagnostics;
    open Microsoft.Quantum.Extensions.Convert;
    open Karatsuba;

    function AssertEq(x: Int, y: Int) : Unit {
        AssertIntEqual(x, y, $"{x} != {y}");
    }

    operation FloorLg2Test() : Unit {
        AssertEq(FloorLg2(0), 0);
        AssertEq(FloorLg2(1), 0);
        AssertEq(FloorLg2(2), 1);
        AssertEq(FloorLg2(3), 1);
        AssertEq(FloorLg2(4), 2);
        AssertEq(FloorLg2(5), 2);
        AssertEq(FloorLg2(6), 2);
        AssertEq(FloorLg2(7), 2);
        AssertEq(FloorLg2(8), 3);
        AssertEq(FloorLg2(9), 3);
        AssertEq(FloorLg2(10), 3);
        AssertEq(FloorLg2(11), 3);
    }

    operation ToffoliSim_MeasureBigIntegerTest() : Unit {
        using (qs = Qubit[100]) {
            X(qs[5]);
            X(qs[95]);
            let r = MeasureBigInteger(LittleEndian(qs));
            if (r != ((ToBigInt(1) <<< 95) + ToBigInt(32))) {
                fail "decoded wrong";
            }
            X(qs[5]);
            X(qs[95]);
        }
    }

    operation CeilLg2Test() : Unit {
        AssertEq(CeilLg2(0), 0);
        AssertEq(CeilLg2(1), 0);
        AssertEq(CeilLg2(2), 1);
        AssertEq(CeilLg2(3), 2);
        AssertEq(CeilLg2(4), 2);
        AssertEq(CeilLg2(5), 3);
        AssertEq(CeilLg2(6), 3);
        AssertEq(CeilLg2(7), 3);
        AssertEq(CeilLg2(8), 3);
        AssertEq(CeilLg2(9), 4);
        AssertEq(CeilLg2(10), 4);
        AssertEq(CeilLg2(11), 4);
    }
}
