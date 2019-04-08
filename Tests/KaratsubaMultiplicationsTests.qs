namespace Tests {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Convert;
    open Microsoft.Quantum.Extensions.Diagnostics;
    open Karatsuba;

    operation AssertProductCase(n_in1: Int, n_in2: Int, v_in1: BigInt, v_in2: BigInt, piece_size: Int) : Unit {
        let n_out = Max([n_in1, n_in2]) * 2;
        if (v_in1 < ToBigInt(0) or v_in1 >= ToBigInt(1) <<< n_in1 or v_in2 < ToBigInt(0) or v_in2 >= ToBigInt(1) <<< n_in2) {
            fail $"Bad test case: {n_in1}, {n_in2}, {v_in1}, {v_in2}, {piece_size}";
        }
        let expected_out = v_in1*v_in2 % (ToBigInt(1) <<< n_out);

        using (b_in1 = Qubit[n_in1]) {
            using (b_in2 = Qubit[n_in2]) {
                using (b_out = Qubit[n_out]) {
                    let r_in1 = LittleEndian(b_in1);
                    let r_in2 = LittleEndian(b_in2);
                    let r_out = LittleEndian(b_out);
                    XorEqualBigInt(r_in1, v_in1);
                    XorEqualBigInt(r_in2, v_in2);
                    _PlusEqualProductUsingKaratsuba_Helper(r_out, r_in1, r_in2, piece_size);
                    let final_in1 = MeasureResetBigInt(r_in1);
                    let final_in2 = MeasureResetBigInt(r_in2);
                    let final_out = MeasureResetBigInt(r_out);
                    if (final_in1 != v_in1 or final_in2 != v_in2 or final_out != expected_out) {
                        fail $"Case failed.
                    AssertProductCase({n_in1}, {n_in2}, {v_in1}, {v_in2}, {piece_size})
                    n_in1={n_in1}
                    n_in2={n_in2}
                    v_in1={v_in1}
                    v_in2={v_in2}
                    piece_size={piece_size}
                    Expected result={expected_out}
                    Actual result={final_out}";
                    }
                }
            }
        }
    }

    operation ToffoliSim_PlusEqualProductUsingKaratsuba__BitCases_Test () : Unit {
        for (n1 in 0..5) {
            for (n2 in n1..5) {
                for (b1 in 0..n1-1) {
                    for (b2 in 0..n2-1) {
                        AssertProductCase(n1, n2, ToBigInt(1)<<<b1, ToBigInt(1)<<<b2, 1);
                    }
                }
            }
        }
    }

    operation ToffoliSim_PlusEqualProductUsingKaratsuba_SmallCases_Test () : Unit {
        for (n1 in 0..2) {
            for (n2 in 0..2) {
                for (v1 in 0..(1<<<n1)-1) {
                    for (v2 in 0..(1 <<< n2)-1) {
                        AssertProductCase(n1, n2, ToBigInt(v1), ToBigInt(v2), 1);
                    }
                }
            }
        }
    }

    operation ToffoliSim_PlusEqualProductUsingKaratsuba_PieceSizes_Test () : Unit {
        for (n in 1..9) {
            AssertProductCase(32, 32, ToBigInt(1620786985), ToBigInt(623629819), n);
        }
    }
}
