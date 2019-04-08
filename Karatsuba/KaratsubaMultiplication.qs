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
            let piece_size = Max([32, 2*CeilLg2(Max([Length(factor1!), Length(factor2!)]))]);
            _PlusEqualProductUsingKaratsuba_Helper(lvalue, factor1, factor2, piece_size);
        }
        adjoint auto;
    }

    operation _PlusEqualProductUsingKaratsuba_Helper(
            lvalue: LittleEndian,
            factor1: LittleEndian,
            factor2: LittleEndian,
            piece_size: Int) : Unit {
        body (...) {
            let piece_count = CeilPowerOf2(CeilMultiple(Max([Length(factor1!), Length(factor2!)]), piece_size) / piece_size);
            let in_buf_piece_size = piece_size + CeilLg2(piece_count);
            let work_buf_piece_size = CeilMultiple(piece_size*2 + CeilLg2(piece_count)*4, piece_size);

            // Create input pieces with enough padding to add them together.
            using (in_bufs_backing1 = Qubit[in_buf_piece_size * piece_count - Length(factor1!)]) {
                using (in_bufs_backing2 = Qubit[in_buf_piece_size * piece_count - Length(factor2!)]) {
                    let in_bufs1 = SplitPadBuffer(factor1!, in_bufs_backing1, piece_size, in_buf_piece_size, piece_count);
                    let in_bufs2 = SplitPadBuffer(factor2!, in_bufs_backing2, piece_size, in_buf_piece_size, piece_count);

                    // Create workspace pieces with enough padding to hold multiplied summed input pieces, and to add them together.
                    using (work_bufs_backing = Qubit[work_buf_piece_size * piece_count * 2]) {
                        let work_bufs = SplitBuffer(work_bufs_backing, work_buf_piece_size);

                        // Add into workspaces, merge into output, then uncompute workspace.
                        _PlusEqualProductUsingKaratsubaOnPieces(work_bufs, in_bufs1, in_bufs2);
                        for (i in 0..piece_size..work_buf_piece_size-1) {
                            let target = LittleEndian(lvalue![i..Length(lvalue!)-1]);
                            let shift = MergeBufferRanges(work_bufs, i, piece_size);
                            PlusEqual(target, shift);
                        }
                        Adjoint _PlusEqualProductUsingKaratsubaOnPieces(work_bufs, in_bufs1, in_bufs2);
                    }
                }
            }
        }
        adjoint auto;
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

                // Input 1 is logically split into two halves (a, b) such that a + 2**h * b equals the input.
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
                // Recursive multiply-add for a*x.
                _PlusEqualProductUsingKaratsubaOnPieces(
                    output_pieces[0..2*h-1],
                    input_pieces_1[0..h-1],
                    input_pieces_2[0..h-1]);
                // Recursive multiply-subtract for b*y.
                Adjoint _PlusEqualProductUsingKaratsubaOnPieces(
                    output_pieces[h..3*h-1],
                    input_pieces_1[h..2*h-1],
                    input_pieces_2[h..2*h-1]);
                // Multiply output by 1-2**h, completing the scaling of the previous two multiply-adds.
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
                // Recursive multiply-add for (a+b)*(x+y).
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
