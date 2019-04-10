namespace Tests {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Diagnostics;
    open Karatsuba;

    operation InitAnd_vs_CCNot_Test () : Unit {
        using (qs = Qubit[4]) {
            InitDual(qs);
            using (t = Qubit()) {
                LetAnd(t, qs[0], qs[1]);
                CCNOT(qs[0], qs[1], t);
            }
            UncomputeDual(qs);
        }
    }

    operation UncomputeAnd_vs_CCNot_Test () : Unit {
        for (_ in 0..9) {
            using (qs = Qubit[4]) {
                InitDual(qs);
                using (t = Qubit()) {
                    CCNOT(qs[0], qs[1], t);
                    DelAnd(t, qs[0], qs[1]);
                }
                UncomputeDual(qs);
            }
        }
    }
}
