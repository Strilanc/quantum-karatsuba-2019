namespace Tests {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Diagnostics;
    open Karatsuba;

    operation ToffoliSim_PlusEqualSquareUsingSchoolbookTest () : Unit {
        using (offset = Qubit[32]) {
            for (k in 0..63) {
                using (target = Qubit[k]) {
                    let src = LittleEndian(offset);
                    let dst = LittleEndian(target);
                    let expectedSrc = k*k + 5; // RandomIntPow2(32);
                    let expectedStart = k;  // RandomIntPow2(k);
                    let expectedDst = (expectedStart + expectedSrc*expectedSrc) % (1 <<< k);
                    XorEqualConst(src, expectedSrc);
                    XorEqualConst(dst, expectedStart);
                    PlusEqualSquareUsingSchoolbook(dst, src);
                    let actualSrc = MeasureInteger(src);
                    let actualDst = MeasureInteger(dst);
                    AssertIntEqual(actualSrc, expectedSrc, $"{actualSrc} != {expectedSrc}");
                    AssertIntEqual(actualDst, expectedDst, $"{actualDst} != {expectedDst}");
                }
            }
        }
    }
}
