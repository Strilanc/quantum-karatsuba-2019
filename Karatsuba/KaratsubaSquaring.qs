namespace Karatsuba {
    open Microsoft.Quantum.Extensions.Bitwise;
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;

    operation PlusEqualSquareUsingKaratsuba(lvalue: LittleEndian, offset: LittleEndian) : Unit {
        let n = Length(offset!);
        let piece_size = Max([32, 2*CeilLg2(Length(offset!))]);
        let piece_count = (n + piece_size  - 1) / piece_size;
        let m = piece_count * piece_size;

        mutable ins = new LittleEndian[piece_count];

        using (workspace = Qubit[7 * m]) {
            // Prepare padded input pieces.
            let i0 = workspace[0..m-1];
            mutable input_pieces = new LittleEndian[piece_count];
            for (k in 0..piece_count-1) {
                let low = k*piece_size;
                let high = Min([low+piece_size-1, Length(offset!)-1]);
                set input_pieces[k] = LittleEndian(
                    offset![low..high] +  // Raw input bits.
                    i0[low..high]);       // Padding so that input pieces can be added together.
            }

            // Prepare padded output pieces to temporarily hold the square.
            let o0 = workspace[1*m..3*m-1];
            let o1 = workspace[3*m..5*m-1];
            let o2 = workspace[5*m..7*m-1];
            mutable output_pieces = new LittleEndian[piece_count*2];
            for (k in 0..piece_count*2-1) {
                let low = k*piece_size;
                let high = low+piece_size-1;
                set output_pieces[k] = LittleEndian(
                    o0[low..high] +  // Basic room for output.
                    o1[low..high] +  // Padding so each piece can hold a squared piece.
                    o2[low..high]);  // Padding so that output pieces can be added together.
            }

            // Initialize temporary registers such that o0 + (o1<<h) + (o2<<2h) = input**2.
            _PlusEqualSquareUsingKaratsubaOnPieces(output_pieces, input_pieces);
            // Use temporary registers to offset lvalue.
            PlusEqual(lvalue, LittleEndian(o0));
            PlusEqual(LittleEndian(lvalue![piece_size..Length(lvalue!)-1]), LittleEndian(o1));
            PlusEqual(LittleEndian(lvalue![2*piece_size..Length(lvalue!)-1]), LittleEndian(o2));
            // Uncompute temporary registers.
            Adjoint _PlusEqualSquareUsingKaratsubaOnPieces(output_pieces, input_pieces);
        }
    }

    operation _PlusEqualSquareUsingKaratsubaOnPieces (output_pieces: LittleEndian[], input_pieces: LittleEndian[]) : Unit {
        body (...) {
            let n = Length(input_pieces);
            if (n <= 1) {
                if (n == 1) {
                    PlusEqualSquareUsingSchoolbook(output_pieces[0], input_pieces[0]);
                }
            } else {
                let h = n >>> 1;

                // Input is logically split into two halves (a, b) such that a + 2**h * b equals the input.

                //-----------------------------------
                // Perform
                //     out += a**2 * (1-2**h)
                //     out -= b**2 * 2**h * (1-2**h)
                //-----------------------------------
                // Temporarily inverse-multiply the output by 1-2**h, so that the following two squared additions are scaled by 1-2**h.
                for (i in h..Length(output_pieces) - 1) {
                    PlusEqual(output_pieces[i], output_pieces[i - h]);
                }
                // Recursive squared addition for a.
                _PlusEqualSquareUsingKaratsubaOnPieces(
                    output_pieces[0..2*h-1],
                    input_pieces[0..h-1]);
                // Recursive squared addition for b.
                Adjoint _PlusEqualSquareUsingKaratsubaOnPieces(
                    output_pieces[h..3*h-1],
                    input_pieces[h..2*h-1]);
                // Multiply output by 1-2**h, completing the scaling of the previous two squared additions.
                for (i in Length(output_pieces) - 1..-1..h) {
                    Adjoint PlusEqual(output_pieces[i], output_pieces[i - h]);
                }

                //-------------------------------
                // Perform
                //     out += (a+b)**2 * 2**h
                //-------------------------------
                // Temporarily store a+b over a.
                for (i in 0..h-1) {
                    PlusEqual(input_pieces[i], input_pieces[i + h]);
                }
                // Recursive squared addition for a+b.
                _PlusEqualSquareUsingKaratsubaOnPieces(
                    output_pieces[h..3*h-1],
                    input_pieces[0..h-1]);
                // Restore a.
                for (i in 0..h-1) {
                    Adjoint PlusEqual(input_pieces[i], input_pieces[i + h]);
                }
            }
        }
        adjoint auto;
    }
}
