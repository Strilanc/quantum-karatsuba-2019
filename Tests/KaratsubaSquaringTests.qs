namespace Tests {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Convert;
    open Microsoft.Quantum.Extensions.Diagnostics;
    open Karatsuba;

    operation ToffoliSim_PlusEqualSquareUsingKaratsubaTest () : Unit {
        for (k in 0..63) {
            using (offset = Qubit[10+k]) {
                using (target = Qubit[20+2*k]) {
                    let src = LittleEndian(offset);
                    let dst = LittleEndian(target);
                    let expectedSrc = ToBigInt(k)*ToBigInt(k) + ToBigInt(5); // RandomIntPow2(32);
                    let expectedStart = ToBigInt(k);  // RandomIntPow2(k);
                    let expectedDst = (expectedStart + expectedSrc*expectedSrc) % (ToBigInt(1) <<< Length(target));
                    XorEqualBigInt(src, expectedSrc);
                    XorEqualBigInt(dst, expectedStart);
                    PlusEqualSquareUsingKaratsuba(dst, src);
                    let actualSrc = MeasureResetBigInteger(src);
                    let actualDst = MeasureResetBigInteger(dst);
                    if (actualSrc != expectedSrc) {
                        fail $"src {actualSrc} != {expectedSrc}";
                    }
                    if (actualDst != expectedDst) {
                        fail $"dst {actualDst} != {expectedDst} == {expectedStart} + {expectedSrc}**2 mod 2**{Length(target)}";
                    }
                }
            }
        }
    }
}
