namespace Tests {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Diagnostics;
    open Karatsuba;

    operation PlusEqualSquareUsingSchoolbookTest () : Unit {
        for (k in 0..7) {
            using (qs = Qubit[3]) {
                using (os = Qubit[5]) {
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
