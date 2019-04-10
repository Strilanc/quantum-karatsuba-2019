namespace Karatsuba {
    open Microsoft.Quantum.Extensions.Bitwise;
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;

    /// # Summary
    /// Performs a += b*b where a and b are little-endian quantum registers.
    ///
    /// # Input
    /// ## lvalue
    /// The target of the addition. The 'a' in 'a += b*b'.
    /// ## offset
    /// The integer amount to square and add into the target. The 'b' in 'a += b*b'.
    operation PlusEqualSquareUsingSchoolbook (lvalue: LittleEndian, offset: LittleEndian) : Unit {
        body (...) {
            let n = Length(offset!);
            using (w = Qubit[n]) {
                for (k in 0..n-1) {
                    let v = LittleEndian(w);

                    for (i in 0..n-1) {
                        if (k != i) {
                            LetAnd(v![i], offset![i], offset![k]);
                        } else {
                            CNOT(offset![k], v![i]);
                        }
                    }

                    let tail = LittleEndian(lvalue![k..Length(lvalue!)-1]);
                    PlusEqual(tail, v);

                    for (i in 0..n-1) {
                        if (k != i) {
                            DelAnd(v![i], offset![i], offset![k]);
                        } else {
                            CNOT(offset![k], v![i]);
                        }
                    }
                }
            }
        }
        adjoint auto;
    }
}
