namespace Karatsuba {
    open Microsoft.Quantum.Extensions.Bitwise;
    open Microsoft.Quantum.Extensions.Convert;
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;

    /// # Summary
    /// Performs a ^^^= b where a and b are little-endian quantum registers.
    ///
    /// # Input
    /// ## lvalue
    /// The target of the xor. The 'a' in 'a ^^^= b'.
    /// ## mask
    /// The integer to xor into the target. The 'b' in 'a ^^^= b'.
    operation XorEqual (lvalue: LittleEndian, mask: LittleEndian) : Unit {
        body (...) {
            if (Length(mask!) > Length(lvalue!)) {
                fail "Length(mask!) > Length(lvalue!)";
            }
            for (i in 0..Length(mask!)-1) {
                CNOT(mask![i], lvalue![i]);
            }
        }
        adjoint self;
        controlled auto;
        controlled adjoint self;
    }

    /// # Summary
    /// Performs a ^^^= k where a is a little-endian quantum register and k is a classical constant.
    ///
    /// Bits in 'k' beyond the range of 'a' are ignored.
    /// For example, 'XorEqualConst(a, -1)' flips all qubits in 'a'.
    ///
    /// # Input
    /// ## lvalue
    /// The target of the xor. The 'a' in 'a ^^^= k'.
    /// ## mask
    /// The integer to xor into the target. The 'k' in 'a ^^^= k'.
    operation XorEqualConst (lvalue: LittleEndian, mask: Int) : Unit {
        body (...) {
            XorEqualBigInt(lvalue, ToBigInt(mask));
        }
        adjoint self;
        controlled auto;
        controlled adjoint self;
    }

    operation XorEqualBigInt (lvalue: LittleEndian, mask: BigInt) : Unit {
        body (...) {
            for (i in 0..Length(lvalue!)-1) {
                if (((mask >>> i) &&& ToBigInt(1)) != ToBigInt(0)) {
                    X(lvalue![i]);
                }
            }
        }
        adjoint self;
        controlled auto;
        controlled adjoint self;
    }
}
