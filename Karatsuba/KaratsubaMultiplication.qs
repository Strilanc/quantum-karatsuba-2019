namespace Karatsuba {
    open Microsoft.Quantum.Extensions.Bitwise;
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;

    /// # Summary
    /// Performs a += b*c where a, b, and c are little-endian quantum registers.
    ///
    /// Has gate complexity O(n^log_2(3)).
    /// Has space complexity O(n).
    ///
    /// # Input
    /// ## lvalue
    /// The target of the addition. The 'a' in 'a += b*c'.
    /// ## factor1
    /// One of the integers being multiplied together. The 'b' in 'a += b*c'.
    /// ## factor2
    /// One of the integers being multiplied together. The 'c' in 'a += b*c'.
    operation PlusEqualProductUsingKaratsuba(
            lvalue: LittleEndian,
            factor1: LittleEndian,
            factor2: LittleEndian) : Unit {
        body (...) {
            let n = Max([Length(factor1!), Length(factor2!)]);
            let piece_size = Max([32, 2*CeilLg2(n)]);
            let piece_count = (n + piece_size  - 1) / piece_size;
            let m = piece_count * piece_size;

            mutable ins = new LittleEndian[piece_count];

            using (workspace = Qubit[8 * m]) {
                // Prepare padded input pieces.
                let i0 = workspace[0..m-1];
                let i1 = workspace[m..2*m-1];
                let input_pieces_1 = build_input_pieces(i0, factor1, piece_size, piece_count);
                let input_pieces_2 = build_input_pieces(i1, factor2, piece_size, piece_count);

                // Prepare padded output pieces to temporarily hold the square.
                let o0 = workspace[2*m..4*m-1];
                let o1 = workspace[4*m..6*m-1];
                let o2 = workspace[6*m..8*m-1];
                let output_pieces = build_output_pieces(o0, o1, o2, piece_size, piece_count);

                // Initialize temporary registers such that o0 + (o1<<h) + (o2<<2h) = input**2.
                _PlusEqualProductUsingKaratsubaOnPieces(
                    output_pieces, input_pieces_1, input_pieces_2);
                Message("COMPUTED out in1 in2");
                peekInts(output_pieces);
                peekInts(input_pieces_1);
                peekInts(input_pieces_2);
                // Use temporary registers to offset lvalue.
                PlusEqual(lvalue, LittleEndian(o0));
                PlusEqual(LittleEndian(lvalue![piece_size..Length(lvalue!)-1]), LittleEndian(o1));
                PlusEqual(LittleEndian(lvalue![2*piece_size..Length(lvalue!)-1]), LittleEndian(o2));
                // Uncompute temporary registers.
                Message("UNCOMPUTING");
                Adjoint _PlusEqualProductUsingKaratsubaOnPieces(
                    output_pieces, input_pieces_1, input_pieces_2);
            }
        }
        adjoint auto;
    }

    function build_input_pieces(
            i0: Qubit[],
            offset: LittleEndian,
            piece_size: Int,
            piece_count: Int) : LittleEndian[] {
        mutable input_pieces = new LittleEndian[piece_count];
        for (k in 0..piece_count-1) {
            let low = k*piece_size;
            let high = Min([low+piece_size-1, Length(offset!)-1]);
            set input_pieces[k] = LittleEndian(
                offset![low..high] +  // Raw input bits.
                i0[low..high]);       // Padding so that input pieces can be added together.
        }
        return input_pieces;
    }

    function build_output_pieces(
            o0: Qubit[],
            o1: Qubit[],
            o2: Qubit[],
            piece_size: Int,
            piece_count: Int) : LittleEndian[] {
        mutable output_pieces = new LittleEndian[piece_count*2];
        for (k in 0..piece_count*2-1) {
            let low = k*piece_size;
            let high = low+piece_size-1;
            set output_pieces[k] = LittleEndian(
                o0[low..high] +  // Basic room for output.
                o1[low..high] +  // Padding so each piece can hold a squared piece.
                o2[low..high]);  // Padding so that output pieces can be added together.
        }
        return output_pieces;
    }

    operation peekInts(vs: LittleEndian[]) : Unit {
        body (...) {
            mutable us = new BigInt[Length(vs)];
            for (i in 0..Length(vs)-1) {
                set us[i] = MeasureSignedBigInt(vs[i]);
            }
            Message($"peekInts {us}");
        }
        adjoint (...) {
            mutable us = new BigInt[Length(vs)];
            for (i in 0..Length(vs)-1) {
                set us[i] = MeasureSignedBigInt(vs[i]);
            }
            Message($"adjoint peekInts {us}");
        }
    }

    operation _PlusEqualProductUsingKaratsubaOnPieces (
            output_pieces: LittleEndian[],
            input_pieces_1: LittleEndian[],
            input_pieces_2: LittleEndian[]) : Unit {
        body (...) {
            let n = Length(input_pieces_1);
            if (n <= 1) {
                if (n == 1) {
                    PlusEqualProductUsingSchoolbook(
                        output_pieces[0],
                        input_pieces_1[0],
                        input_pieces_2[0]);
                }
            } else {
                let h = n >>> 1;

                // Input is logically split into two halves (a, b) such that a + 2**h * b equals the input.
                // Input 2 is logically split into two halves (x, y) such that x + 2**h * y equals the input.

                //-----------------------------------
                // Perform
                //     out += a*x * (1-2**h)
                //     out -= b*y * 2**h * (1-2**h)
                //-----------------------------------
                // Temporarily inverse-multiply the output by 1-2**h, so that the following two multiplied additions are scaled by 1-2**h.
                for (i in h..Length(output_pieces) - 1) {
                    PlusEqual(output_pieces[i], output_pieces[i - h]);
                }
                // Recursive multiplied addition for a.
                _PlusEqualProductUsingKaratsubaOnPieces(
                    output_pieces[0..2*h-1],
                    input_pieces_1[0..h-1],
                    input_pieces_2[0..h-1]);
                // Recursive multiplied addition for b.
                Adjoint _PlusEqualProductUsingKaratsubaOnPieces(
                    output_pieces[h..3*h-1],
                    input_pieces_1[h..2*h-1],
                    input_pieces_2[h..2*h-1]);
                // Multiply output by 1-2**h, completing the scaling of the previous two multiplied additions.
                for (i in Length(output_pieces) - 1..-1..h) {
                    Adjoint PlusEqual(output_pieces[i], output_pieces[i - h]);
                }

                //-------------------------------
                // Perform
                //     out += (a+b)*(x+y) * 2**h
                //-------------------------------
                // Temporarily store a+b over a and x+y over x.
                for (i in 0..h-1) {
                    PlusEqual(input_pieces_1[i], input_pieces_1[i + h]);
                    PlusEqual(input_pieces_2[i], input_pieces_2[i + h]);
                }
                // Recursive multiplied addition for (a+b)*(x+y).
                _PlusEqualProductUsingKaratsubaOnPieces(
                    output_pieces[h..3*h-1],
                    input_pieces_1[0..h-1],
                    input_pieces_2[0..h-1]);
                // Restore a and x.
                for (i in 0..h-1) {
                    Adjoint PlusEqual(input_pieces_1[i], input_pieces_1[i + h]);
                    Adjoint PlusEqual(input_pieces_2[i], input_pieces_2[i + h]);
                }
            }
        }
        adjoint auto;
    }
}
