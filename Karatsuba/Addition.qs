namespace Karatsuba {
    open Microsoft.Quantum.Extensions.Bitwise;
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    
    /// # Summary
    /// Performs a += b + c where a and b are little-endian quantum registers and c is a carry qubit.
    ///
    /// If you want a carry *output*, append a qubit to the lvalue register.
    ///
    /// # Input
    /// ## lvalue
    /// The target of the addition. The 'a' in 'a += b + c'.
    /// ## offset
    /// The integer amount to add into the target. The 'b' in 'a += b + c'.
    /// ## carry_in
    /// The carry to include in the addition. The 'c' in 'a += b + c'.
    ///
    /// # References
    /// - "A new quantum ripple-carry addition circuit"
    ///        Steven A. Cuccaro, Thomas G. Draper, Samuel A. Kutin, David Petrie Moulton
    ///        https://arxiv.org/abs/quant-ph/0410184
    operation PlusEqualWithCarry (lvalue: LittleEndian, offset: LittleEndian, carryIn: Qubit) : Unit {
        body (...) {
            // Construction requires similarly-sized registers.
            let n = Length(offset!);
            let m = Length(lvalue!);
            if (m != n and m != n + 1) {
                fail $"Length(lvalue) ({m}) != Length(offset) ({n}) && Length(lvalue) != Length(offset) + 1";
            }

            let coffset = [carryIn] + offset!;

            // Propagate carry.
            for (i in 0..n-1) {
                Maj(coffset[i], lvalue![i], offset![i]);
            }

            // Carry output.
            if (m == n + 1) {
                CNOT(coffset[n], lvalue![n]);
            }

            // Apply and uncompute carries.
            for (i in n-1..-1..0) {
                Uma(coffset[i], lvalue![i], offset![i]);
            }
        }
        adjoint auto;
    }

    /// # Summary
    /// Performs a += b where a and b are little-endian quantum registers.
    ///
    /// # Input
    /// ## lvalue
    /// The target of the addition. The 'a' in 'a += b'.
    /// ## offset
    /// The amount to add into the target. The 'b' in 'a += b'.
    operation PlusEqual (lvalue: LittleEndian, offset: LittleEndian) : Unit {
        body (...) {
            using (carryIn = Qubit()) {
                let trimmedOffset = LittleEndian(offset![0..Min([Length(lvalue!), Length(offset!)])-1]);
                using (pad = Qubit[Max([0, Length(lvalue!) - Length(trimmedOffset!) - 1])]) {
                    let paddedOffset = LittleEndian(offset! + pad);
                    PlusEqualWithCarry(lvalue, paddedOffset, carryIn);
                }
            }
        }
        adjoint auto;
    }

    /// # Summary
    /// Performs a -= b + c where a and b are little-endian quantum registers and c is a carry qubit.
    ///
    /// If you want a carry *output*, append a qubit to the lvalue register.
    ///
    /// # Input
    /// ## lvalue
    /// The target of the subtraction. The 'a' in 'a -= b + c'.
    /// ## offset
    /// The integer amount to subtract out of the target. The 'b' in 'a -= b + c'.
    /// ## carry_in
    /// The carry to include in the subtraction. The 'c' in 'a -= b + c'.
    operation MinusEqualWithCarry (lvalue: LittleEndian, offset: LittleEndian, carryIn: Qubit) : Unit {
        body (...) {
            Adjoint PlusEqualWithCarry(lvalue, offset, carryIn);
        }
        adjoint auto;
    }

    /// # Summary
    /// Performs a -= b where a and b are little-endian registers.
    ///
    /// # Input
    /// ## lvalue
    /// The target of the subtraction. The 'a' in 'a -= b'.
    /// ## offset
    /// The amount to subtract out of the target. The 'b' in 'a -= b'.
    operation MinusEqual (lvalue: LittleEndian, offset: LittleEndian) : Unit {
        body (...) {
            Adjoint PlusEqual(lvalue, offset);
        }
        adjoint auto;
    }

    operation Maj (a: Qubit, b: Qubit, c: Qubit) : Unit {
        body (...) {
            CNOT(c, a);
            CNOT(c, b);
            CCNOT(a, b, c);
        }
        adjoint auto;
    }

    operation Uma (a: Qubit, b: Qubit, c: Qubit) : Unit {
        body (...) {
            CCNOT(a, b, c);
            CNOT(c, a);
            CNOT(a, b);
        }
        adjoint auto;
    }
}
