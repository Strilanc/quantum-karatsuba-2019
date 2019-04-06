namespace Tests {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Diagnostics;
    open Karatsuba;

    operation XorEqual_vs_CNots_Test () : Unit {
        using (qs = Qubit[8]) {
            InitDual(qs);
            XorEqual(LittleEndian(qs[2..3]), LittleEndian(qs[0..1]));
            CNOT(qs[0], qs[2]);
            CNOT(qs[1], qs[3]);
            UncomputeDual(qs);
        }
    }

    operation XorEqualConst_Test () : Unit {
        using (qs = Qubit[6]) {
            let r = LittleEndian(qs);
            for (i in 0..60) {
                XorEqualConst(r, i);
                let v = MeasureInteger(r); // resets to 0
                AssertIntEqual(v, i, "");
            }
        }
    }
}
