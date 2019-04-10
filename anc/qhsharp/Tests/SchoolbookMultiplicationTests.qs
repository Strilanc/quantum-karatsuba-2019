namespace Tests {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Diagnostics;
    open Karatsuba;

    operation ToffoliSim_PlusEqualProductUsingSchoolbookTest () : Unit {
        using (f1 = Qubit[32]) {
            using (f2 = Qubit[32]) {
                for (k in 0..63) {
                    using (target = Qubit[k]) {
                        let src1 = LittleEndian(f1);
                        let src2 = LittleEndian(f2);
                        let dst = LittleEndian(target);
                        let expectedSrc1 = k*k + 5; // RandomIntPow2(32);
                        let expectedSrc2 = k + 4; // RandomIntPow2(32);
                        let expectedStart = k;  // RandomIntPow2(k);
                        let expectedDst = (expectedStart + expectedSrc1*expectedSrc2) % (1 <<< k);
                        XorEqualConst(src1, expectedSrc1);
                        XorEqualConst(src2, expectedSrc2);
                        XorEqualConst(dst, expectedStart);
                        PlusEqualProductUsingSchoolbook(dst, src1, src2);
                        let actualSrc1 = MeasureInteger(src1);
                        let actualSrc2 = MeasureInteger(src2);
                        let actualDst = MeasureInteger(dst);
                        AssertIntEqual(actualSrc1, expectedSrc1, $"Mangled src1. {actualSrc1} != {expectedSrc1}");
                        AssertIntEqual(actualSrc2, expectedSrc2, $"Mangled src2. {actualSrc2} != {expectedSrc2}");
                        AssertIntEqual(actualDst, expectedDst, $"Wrong result. {actualDst} != {expectedDst} == {expectedStart} + {expectedSrc1}*{expectedSrc2} (mod 2**{k})");
                    }
                }
            }
        }
    }
}
