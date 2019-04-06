namespace Tests {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Diagnostics;
    open Karatsuba;
    
    operation InitDual(qs: Qubit[]) : Unit {
        let n = Length(qs) >>> 1;
        for (i in 0..n-1) {
            H(qs[i]);
            CNOT(qs[i], qs[i+n]);
        }
    }

    operation UncomputeDual(qs: Qubit[]) : Unit {
        let n = Length(qs) >>> 1;
        for (i in 0..n-1) {
            CNOT(qs[i], qs[i+n]);
            H(qs[i]);
        }
    }
}
