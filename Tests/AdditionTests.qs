namespace Tests {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Diagnostics;
    open Karatsuba;

    operation PlusEqual_vs_ModularAddProductLE_Test () : Unit {
        using (qs = Qubit[12]) {
            let src = LittleEndian(qs[0..2]);
            let dst = LittleEndian(qs[3..5]);
            InitDual(qs);
            PlusEqual(dst, src);
            ModularAddProductLE((1<<<3)-1, 1<<<3, src, dst);
            UncomputeDual(qs);
        }
    }

    operation PlusEqualWithCarry_vs_ModularAddProductLE_Test () : Unit {
        using (qs = Qubit[10]) {
            let src = LittleEndian(qs[0..1]);
            let dst = LittleEndian(qs[2..3]);
            let car = qs[4];
            InitDual(qs);
            PlusEqualWithCarry(dst, src, car);
            ModularAddProductLE((1<<<2)-1, 1<<<2, src, dst);
            Controlled IntegerIncrementLE([car], (-1, dst));
            UncomputeDual(qs);
        }
    }

    operation PlusEqual_CarryOut_vs_ModularAddProductLE_Test () : Unit {
        using (qs = Qubit[10]) {
            let src = LittleEndian(qs[0..1]);
            let dst = LittleEndian(qs[2..4]);
            InitDual(qs);
            PlusEqual(dst, src);
            ModularAddProductLE((1<<<3)-1, 1<<<3, src, dst);
            UncomputeDual(qs);
        }
    }

    operation ToffoliSim_PlusEqual_Sizes_Test () : Unit {
        using (offset = Qubit[32]) {
            for (k in 0..63) {
                using (target = Qubit[k]) {
                    let src = LittleEndian(offset);
                    let dst = LittleEndian(target);
                    let expectedSrc = (1 <<< 31) + k*k;
                    let expectedDst = (expectedSrc + k) % (1 <<< k);
                    XorEqualConst(src, expectedSrc);
                    XorEqualConst(dst, k);
                    PlusEqual(dst, src);
                    let actualSrc = MeasureInteger(src);
                    let actualDst = MeasureInteger(dst);
                    AssertIntEqual(actualSrc, expectedSrc, $"{actualSrc} != {expectedSrc}");
                    AssertIntEqual(actualDst, expectedDst, $"{actualDst} != {expectedDst}");
                }
            }
        }
    }
}
