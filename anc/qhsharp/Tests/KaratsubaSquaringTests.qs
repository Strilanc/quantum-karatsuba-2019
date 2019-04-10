namespace Tests {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Convert;
    open Microsoft.Quantum.Extensions.Diagnostics;
    open Karatsuba;

    operation AssertSquareCase(n_in: Int, v_in: BigInt, piece_size: Int) : Unit {
        let n_out = n_in * 2;
        if (v_in < ToBigInt(0) or v_in >= ToBigInt(1) <<< n_in) {
            fail $"Bad test case: {n_in}, {v_in}, {piece_size}";
        }
        let expected_out = v_in*v_in % (ToBigInt(1) <<< n_out);

        using (b_in = Qubit[n_in]) {
            using (b_out = Qubit[n_out]) {
                let r_in = LittleEndian(b_in);
                let r_out = LittleEndian(b_out);
                XorEqualBigInt(r_in, v_in);
                _PlusEqualSquareUsingKaratsuba_Helper(r_out, r_in, piece_size);
                let final_in = MeasureResetBigInt(r_in);
                let final_out = MeasureResetBigInt(r_out);
                if (final_in != v_in or final_out != expected_out) {
                    fail $"Case failed.
                AssertSquareCase({n_in}, {v_in}, {piece_size})
                n_in={n_in}
                v_in={v_in}
                piece_size={piece_size}
                Expected result={expected_out}
                Actual result={final_out}";
                }
            }
        }
    }

    operation ToffoliSim_PlusEqualSquareUsingKaratsuba_IndividualBits_Test () : Unit {
        for (n in 0..9) {
            for (b in 0..n-1) {
                AssertSquareCase(n, ToBigInt(1)<<<b, 1);
            }
        }
    }

    operation ToffoliSim_PlusEqualSquareUsingKaratsuba_SmallCases_Test() : Unit {
        for (n in 0..4) {
            for (v in 0..1<<<n-1) {
                AssertSquareCase(n, ToBigInt(v), 1);
            }
        }
    }

    operation ToffoliSim_PlusEqualSquareUsingKaratsuba_HistoricalFailures_Test() : Unit {
        AssertSquareCase(
            8,
            BoolsToBigInt([true,true,true,true,true,true,true,true,false]),
            4);

        // TODO: re-enable if performance improves.
        // AssertSquareCase(
        //     207,
        //     BoolsToBigInt([true,true,true,true,false,true,true,true,false,false,true,true,false,false,true,true,true,false,false,true,false,false,true,false,true,true,true,false,true,false,true,true,true,false,false,true,true,true,true,true,true,true,false,true,true,false,true,false,true,false,true,true,false,false,false,true,true,false,false,false,false,false,true,true,true,false,false,false,false,false,false,true,false,true,false,true,true,false,false,true,true,true,true,true,true,false,true,true,true,false,true,false,true,false,false,false,true,false,false,true,false,true,false,false,true,true,false,false,false,true,true,true,false,true,true,true,true,false,true,false,false,true,true,false,true,false,true,false,false,false,true,false,false,true,false,true,true,false,true,true,true,true,true,true,true,false,true,false,true,true,true,false,true,false,true,true,false,true,true,true,false,false,false,false,false,true,false,false,true,false,true,false,false,false,false,true,true,false,false,false,true,true,true,true,true,true,true,true,false,true,true,false,false,false,false,false,false,true,false,true,true,true,true,true,true,true,false]),
        //     32);
        // AssertSquareCase(
        //     128,
        //     BoolsToBigInt([true,true,true,false,true,false,false,true,false,false,false,true,true,true,false,false,true,true,false,false,false,false,false,false,true,true,false,false,false,true,false,false,false,false,false,false,false,true,false,true,false,false,false,true,true,true,true,false,true,false,true,false,false,false,true,false,false,true,true,false,true,false,true,true,false,false,true,false,true,false,false,true,false,true,true,true,true,false,false,true,true,false,false,true,true,true,true,false,true,false,false,false,true,true,false,false,true,true,false,true,false,false,true,true,false,false,true,false,true,true,true,true,false,false,true,true,false,false,true,false,false,true,true,true,true,false,true,true,false]),
        //     32);
        // AssertSquareCase(
        //     66,
        //     BoolsToBigInt([true,true,true,false,true,false,true,false,false,false,true,false,true,true,false,true,true,false,true,true,true,true,true,true,false,false,false,false,true,true,false,false,true,true,false,true,true,true,false,true,false,true,false,true,true,false,false,true,true,true,true,true,false,false,true,false,true,false,true,false,false,false,true,false,true,false]),
        //     32);
    }

    operation ToffoliSim_PlusEqualSquareUsingKaratsuba_PieceSizes_Test () : Unit {
        for (n in 1..9) {
            AssertSquareCase(32, ToBigInt(1620786985), n);
        }
    }

    operation ToffoliSim_PlusEqualSquareUsingKaratsuba_Fuzz_Test() : Unit {
        // TODO: When ToffoliSim supports random numbers, generate on the fly instead of pre-baking.

        AssertSquareCase(
            6,
            BoolsToBigInt([true,false,true,true,false]),
            32);

        AssertSquareCase(
            39,
            BoolsToBigInt([true,true,true,false,true,true,true,true,true,false,true,false,true,true,false,true,false,true,true,true,false,false,false,false,true,false,false,true,false,false,false,false,false,false,false]),
            32);

        // TODO: re-enable if performance improves.
        // AssertSquareCase(
        //     93,
        //     BoolsToBigInt([true,true,false,true,false,true,false,true,true,true,false,true,false,true,false,true,true,false,true,true,false,true,true,true,false,false,true,true,true,true,true,false,false,true,false,false,true,true,true,false,false,true,false,true,false,false,true,false,false,true,true,true,true,false,false,true,true,false,false,true,true,true,false,true,true,true,false,false,false,true,false,false,true,false,true,false,false,false,false,true,true,false,true,false,false,true,false,false,false,true,true,true,false]),
        //     32);

        // AssertSquareCase(
        //     116,
        //     BoolsToBigInt([true,false,true,true,true,true,true,true,true,false,false,false,true,true,false,true,false,false,false,true,false,true,true,true,false,false,true,false,true,true,true,false,false,false,false,true,false,false,true,false,false,true,false,true,false,false,false,false,true,true,true,true,false,true,true,true,false,true,true,false,true,false,false,false,false,false,true,false,true,true,true,false,true,true,true,false,true,true,false,false,true,true,true,true,true,true,false,true,true,false,false,false,true,false,true,true,true,false,true,false,true,true,true,false,true,true,true,true,true,false,false,false,true,true,true,false]),
        //     32);

        // AssertSquareCase(
        //     202,
        //     BoolsToBigInt([true,true,false,false,false,false,false,true,true,false,false,true,true,false,false,false,true,true,true,true,true,false,true,true,false,true,true,false,false,false,false,true,true,true,false,true,true,true,false,false,true,true,true,true,true,true,false,false,false,false,true,true,false,true,true,true,false,false,false,true,true,true,false,false,false,false,true,true,false,false,false,true,false,false,true,true,true,false,false,true,true,false,true,false,false,true,true,true,true,true,true,false,false,true,false,true,true,false,false,false,false,false,true,true,true,false,true,true,true,true,true,true,false,true,false,true,true,true,true,false,true,true,true,true,false,true,true,true,false,true,true,false,true,true,true,true,true,false,true,true,false,false,true,false,true,false,false,false,false,true,true,false,true,true,true,false,false,true,false,false,false,false,true,true,true,false,true,false,false,true,true,false,true,true,false,false,false,false,true,true,false,true,true,false,true,true,false,true,true,false,false,false,false,false,false,false,true,false,true,false,false]),
        //     32);

        // AssertSquareCase(
        //     61,
        //     BoolsToBigInt([true,false,true,true,false,false,false,true,true,true,false,false,true,true,true,true,false,false,false,false,true,true,false,false,false,true,true,true,false,true,true,false,false,true,false,false,true,true,false,true,false,false,true,true,true,true,false,false,true,true,false,true,true,false,true,false,false,true,false,false,true,false]),
        //     32);

        // AssertSquareCase(
        //     11,
        //     BoolsToBigInt([true,true,false,false,false,false,false,false,true,false,true,false]),
        //     32);

        // AssertSquareCase(
        //     150,
        //     BoolsToBigInt([true,false,false,false,true,false,false,true,false,true,false,false,false,true,false,true,true,false,true,true,false,false,false,false,true,false,true,true,false,true,true,false,false,true,false,true,false,true,false,true,false,false,true,false,false,false,false,true,false,true,false,true,false,true,false,true,false,false,false,true,true,true,false,true,false,true,false,false,true,false,false,false,false,false,false,true,false,true,false,true,false,false,false,true,false,false,false,true,true,false,true,true,false,false,false,false,true,false,false,true,true,true,true,true,false,false,true,false,false,true,false,true,true,false,false,false,true,false,false,true,true,true,false,false,true,true,true,false,true,false,true,false,false,true,true,false,true,true,true,true,true,false,true,true,true,false,true,false]),
        //     32);

        // AssertSquareCase(
        //     116,
        //     BoolsToBigInt([true,true,false,true,true,false,true,true,true,true,false,true,true,true,false,false,true,false,true,false,true,true,false,false,true,true,false,false,true,false,true,true,true,false,true,false,true,false,true,true,true,true,false,true,false,false,true,true,true,false,true,false,false,false,true,true,true,true,true,false,false,false,true,false,false,true,false,true,false,false,true,false,true,false,true,false,true,false,true,false,false,false,false,false,true,true,false,true,false,false,true,false,true,true,true,false,true,true,false,true,true,false,false,false,false,true,false,false,true,false,false,true,true,false]),
        //     32);

        // AssertSquareCase(
        //     91,
        //     BoolsToBigInt([true,true,true,true,false,true,false,false,false,false,false,true,false,false,false,false,false,true,false,true,false,false,false,false,true,false,false,true,false,false,false,true,false,false,true,false,false,true,true,false,false,true,false,false,false,true,true,false,true,false,false,true,false,true,true,true,false,true,false,true,true,true,true,false,true,true,false,true,false,true,true,true,true,true,true,false,false,false,false,true,false,true,false,true,true,false,true,false,false,true,false]),
        //     32);

        // AssertSquareCase(
        //     123,
        //     BoolsToBigInt([true,true,true,false,true,false,true,false,false,true,false,false,false,false,false,true,false,true,true,false,false,true,true,true,true,true,false,true,true,true,true,false,false,true,false,false,false,true,false,true,false,false,true,false,false,false,true,true,true,true,false,true,false,true,false,false,false,true,true,true,false,false,false,false,false,false,true,false,true,false,true,true,true,false,true,true,false,true,true,false,false,false,false,false,false,true,false,true,false,true,true,false,true,true,true,false,false,true,false,false,false,false,true,true,true,false,true,false,true,true,false,false,true,false,true,false,true,false,true,true,true,false,true,false]),
        //     32);

        // AssertSquareCase(
        //     160,
        //     BoolsToBigInt([true,true,true,true,false,true,false,true,false,false,true,false,true,true,true,false,false,true,true,false,true,false,true,true,false,true,true,false,false,false,false,false,false,false,true,true,true,false,false,false,true,true,true,false,false,true,true,true,false,true,false,true,true,true,false,false,false,false,false,true,true,true,true,true,false,false,true,true,true,true,true,false,true,true,true,true,false,true,false,false,true,false,true,true,true,true,true,true,false,true,true,false,false,false,false,false,false,true,true,true,true,false,false,false,true,false,true,false,true,true,true,false,true,true,false,true,false,true,true,true,true,true,false,false,false,true,false,false,false,false,true,true,true,false,false,false,false,true,false,true,false,false,false,false,false,false,true,false,false,true,false,true,true,false,false,false,true,true,false,false]),
        //     32);

        // AssertSquareCase(
        //     174,
        //     BoolsToBigInt([true,false,true,true,false,false,true,true,false,true,false,false,true,false,true,true,true,true,true,true,true,true,false,true,true,false,true,false,true,false,true,true,true,true,true,true,false,true,true,false,false,false,false,true,true,false,true,true,false,true,true,true,true,true,true,false,false,true,false,false,true,true,false,false,false,true,true,false,true,true,true,true,true,true,false,true,true,true,true,true,true,true,false,true,true,false,false,true,true,false,true,true,true,false,false,false,false,true,true,false,true,true,true,false,true,true,false,false,true,true,false,true,true,false,true,true,true,false,true,true,false,false,false,true,true,true,false,false,false,true,true,false,false,true,true,false,true,true,true,false,true,true,true,true,false,false,false,true,true,false,false,false,true,false,false,false,true,false,true,false,true,false,false,true,false,true,false,true,false,true,false,true,true,false]),
        //     32);

        // AssertSquareCase(
        //     104,
        //     BoolsToBigInt([true,false,false,true,true,false,true,true,false,false,true,true,false,true,true,true,false,false,true,true,true,false,false,true,false,false,true,true,true,true,true,true,false,false,false,false,false,false,true,true,false,true,false,true,true,false,true,true,false,true,false,false,false,false,true,false,false,true,false,true,false,false,false,true,true,false,true,true,true,true,true,false,false,true,true,false,false,false,true,false,true,false,true,true,false,false,false,false,false,true,true,false,true,false,false,true,false,false,true,false,false,false]),
        //     32);

        // AssertSquareCase(
        //     32,
        //     BoolsToBigInt([true,false,false,false,true,false,false,true,true,false,true,true,false,false,true,false,true,false,false,false,true,false,true,true,false,true,false,false,true,false,true,false]),
        //     32);

        // AssertSquareCase(
        //     69,
        //     BoolsToBigInt([true,false,true,false,false,true,false,true,true,true,false,false,false,false,true,true,false,false,true,true,true,false,true,true,true,true,false,false,false,true,false,true,false,true,false,false,true,true,true,true,false,true,false,false,false,false,false,false,true,true,true,false,false,false,false,true,true,true,false,true,true,true,true,true,false,false,true,false,true,false]),
        //     32);

        // AssertSquareCase(
        //     27,
        //     BoolsToBigInt([true,true,false,true,false,true,true,false,false,true,true,false,true,false,true,true,false,false,true,true,false,true,false,false,false,true,false]),
        //     32);

        // AssertSquareCase(
        //     97,
        //     BoolsToBigInt([true,false,false,false,true,true,false,false,true,false,true,false,true,true,false,false,false,false,true,true,false,true,true,false,false,false,false,true,true,false,false,true,true,true,true,true,false,false,true,true,true,true,false,false,true,true,true,true,false,false,true,true,true,false,false,false,true,true,false,false,false,false,true,true,false,false,false,false,true,true,false,true,false,false,false,false,true,false,false,true,false,true,false,false,true,true,false,false,false,true,true,true,false,true,true,false]),
        //     32);

        // AssertSquareCase(
        //     179,
        //     BoolsToBigInt([true,true,false,false,false,true,true,false,false,true,true,false,false,true,true,false,true,false,true,true,true,true,false,false,true,false,true,false,true,false,false,true,true,false,true,false,true,false,true,true,false,false,true,true,true,true,false,false,true,false,true,false,false,false,false,true,true,false,false,false,false,false,true,false,false,true,true,true,true,false,false,false,false,false,true,true,false,false,true,true,true,false,false,true,false,false,true,false,true,false,true,true,false,false,true,true,true,true,false,false,true,false,false,true,true,true,false,false,false,false,true,true,false,false,true,false,false,true,false,false,true,false,true,false,false,true,true,false,true,false,true,true,true,true,true,false,false,false,true,false,true,false,false,true,true,true,false,false,false,true,false,true,false,false,false,false,false,true,false,true,true,true,true,false,true,true,true,false,false,false,true,true,true,false,false,true,false,true,false]),
        //     32);

        // AssertSquareCase(
        //     194,
        //     BoolsToBigInt([true,false,true,true,true,true,true,false,true,false,true,false,true,false,true,false,true,false,false,true,false,false,false,false,false,true,false,false,false,false,false,false,false,false,false,true,false,true,false,true,false,false,true,true,false,true,false,true,true,false,false,false,true,false,true,false,true,true,false,true,false,false,false,false,false,true,false,false,false,false,false,false,true,true,false,true,true,false,false,true,false,false,false,true,false,false,false,false,false,false,false,false,true,false,false,true,false,true,true,true,true,true,false,false,false,false,false,true,false,true,false,false,false,true,true,false,false,true,false,false,true,true,true,false,false,true,false,true,false,false,false,false,true,true,true,true,true,false,false,true,true,false,true,true,true,true,false,true,false,false,false,false,true,false,true,false,true,true,false,false,true,false,true,false,false,true,false,false,true,true,true,true,true,false,true,true,false,true,true,true,false,false,false,false,true,true,false,true,true,false,false,false,false]),
        //     32);
    }
}
