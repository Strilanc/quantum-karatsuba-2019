namespace Karatsuba {
    open Microsoft.Quantum.Extensions.Bitwise;
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;

    /// # Summary
    /// Performs a += b*c where a, b, and c are little-endian quantum registers.
    ///
    /// # Input
    /// ## lvalue
    /// The target of the addition. The 'a' in 'a += b*c'.
    /// ## factor1
    /// One of the integers being multiplied together. The 'b' in 'a += b*c'.
    /// ## factor2
    /// One of the integers being multiplied together. The 'c' in 'a += b*c'.
    operation PlusEqualProductUsingSchoolbook (
            lvalue: LittleEndian,
            factor1: LittleEndian,
            factor2: LittleEndian) : Unit {
        body (...) {
            let n1 = Length(factor1!);
            let n2 = Length(factor2!);
            using (w = Qubit[n2]) {
                for (k in 0..n1-1) {
                    let v = LittleEndian(w);

                    for (i in 0..n2-1) {
                        LetAnd(v![i], factor2![i], factor1![k]);
                    }

                    let tail = LittleEndian(lvalue![k..Length(lvalue!)-1]);
                    PlusEqual(tail, v);

                    for (i in 0..n2-1) {
                        DelAnd(v![i], factor2![i], factor1![k]);
                    }
                }
            }
        }
        adjoint auto;
    }
}
