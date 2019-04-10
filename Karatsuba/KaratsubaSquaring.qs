namespace Karatsuba {
    open Microsoft.Quantum.Extensions.Bitwise;
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;

    /// # Summary
    /// Performs a += b*b where a and b are little-endian quantum registers.
    ///
    /// Has gate complexity O(n^log_2(3)).
    /// Has space complexity O(n).
    ///
    /// # Input
    /// ## lvalue
    /// The target of the addition. The 'a' in 'a += b*b'.
    /// ## offset
    /// The integer amount to square and add into the target. The 'b' in 'a += b*b'.
    operation PlusEqualSquareUsingKaratsuba(lvalue: LittleEndian, offset: LittleEndian) : Unit {
        body (...) {
            let piece_size = Max([32, 2*CeilLg2(Length(offset!))]);
            _PlusEqualSquareUsingKaratsuba_Helper(lvalue, offset, piece_size);
        }
        adjoint auto;
    }

    operation _PlusEqualSquareUsingKaratsuba_Helper(lvalue: LittleEndian, offset: LittleEndian, piece_size: Int) : Unit {
        body (...) {
            let piece_count = CeilPowerOf2(CeilMultiple(Length(offset!), piece_size) / piece_size);
            let in_buf_piece_size = piece_size + CeilLg2(piece_count);
            let work_buf_piece_size = CeilMultiple(piece_size*2 + CeilLg2(piece_count)*4, piece_size);

            // Create input pieces with enough padding to add them together.
            using (in_bufs_backing = Qubit[in_buf_piece_size * piece_count - Length(offset!)]) {
                let in_bufs = SplitPadBuffer(offset!, in_bufs_backing, piece_size, in_buf_piece_size, piece_count);

                // Create workspace pieces with enough padding to hold squared summed input pieces, and to add them together.
                using (work_bufs_backing = Qubit[work_buf_piece_size * piece_count * 2]) {
                    let work_bufs = SplitBuffer(work_bufs_backing, work_buf_piece_size);

                    // Add into workspaces, merge into output, then uncompute workspace.
                    _PlusEqualSquareUsingKaratsubaOnPieces(work_bufs, in_bufs);
                    for (i in 0..piece_size..work_buf_piece_size-1) {
                        let target = LittleEndian(lvalue![i..Length(lvalue!)-1]);
                        let shift = MergeBufferRanges(work_bufs, i, piece_size);
                        PlusEqual(target, shift);
                    }
                    Adjoint _PlusEqualSquareUsingKaratsubaOnPieces(work_bufs, in_bufs);
                }
            }
        }
        adjoint auto;
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

                // Input is logically split into two halves (a, b) such that a + 2**(wh) * b equals the input.

                //-----------------------------------
                // Perform
                //     out += a**2 * (1-2**(wh))
                //     out -= b**2 * 2**(wh) * (1-2**(wh))
                //-----------------------------------
                // Temporarily inverse-multiply the output by 1-2**(wh), so that the following two squared additions are scaled by 1-2**(wh).
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
                // Multiply output by 1-2**(wh), completing the scaling of the previous two squared additions.
                for (i in Length(output_pieces) - 1..-1..h) {
                    Adjoint PlusEqual(output_pieces[i], output_pieces[i - h]);
                }

                //-------------------------------
                // Perform
                //     out += (a+b)**2 * 2**(wh)
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

    function SplitPadBuffer(buf: Qubit[], pad: Qubit[], base_piece_size: Int, desired_piece_size: Int, piece_count: Int) : LittleEndian[] {
        mutable result = new LittleEndian[piece_count];
        mutable k_pad = 0;
        for (i in 0..piece_count-1) {
            let k_buf = i*base_piece_size;
            if (k_buf >= Length(buf)) {
                set result[i] = LittleEndian(new Qubit[0]);
            } else {
                set result[i] = LittleEndian(buf[k_buf..Min([k_buf+base_piece_size, Length(buf)])-1]);
            }
            let missing = desired_piece_size - Length(result[i]!);
            set result[i] = LittleEndian(result[i]! + pad[k_pad..k_pad+missing-1]);
            set k_pad = k_pad + missing;
        }
        return result;
    }

    function SplitBuffer(buf: Qubit[], piece_size: Int) : LittleEndian[] {
        mutable result = new LittleEndian[Length(buf)/piece_size];
        for (i in 0..piece_size..Length(buf)-1) {
            set result[i/piece_size] = LittleEndian(buf[i..i+piece_size-1]);
        }
        return result;
    }

    function MergeBufferRanges(work_registers: LittleEndian[], start: Int, len: Int) : LittleEndian {
        mutable result = new Qubit[len*Length(work_registers)];
        for (i in 0..Length(work_registers)-1) {
            for (j in 0..len-1) {
                set result[i*len + j] = (work_registers[i]!)[start+j];
            }
        }
        return LittleEndian(result);
    }
}
