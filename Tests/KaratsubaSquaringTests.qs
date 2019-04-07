namespace Tests {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Diagnostics;
    open Karatsuba;

    operation ToffoliSim_PlusEqualSquareUsingKaratsubaTest () : Unit {
        for (k in 0..7) {
            using (qs = Qubit[30]) {
                using (os = Qubit[50]) {
                    let input = LittleEndian(qs);
                    let output = LittleEndian(os);
                    XorEqualConst(input, k);
                    XorEqualConst(output, 1 + k);
                    PlusEqualSquareUsingSchoolbook(output, input);
                    XorEqualConst(input, k);
                    XorEqualConst(output, 1 + k + k*k);
                }
            }
        }
    }
}
