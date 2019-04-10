namespace Karatsuba {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Convert;
    open Microsoft.Quantum.Primitive;

    operation RunKaratsubaMultiplicationCircuit (a: BigInt, b: BigInt) : BigInt {
        let na = CeilBigLg2(a + ToBigInt(1));
        let nb = CeilBigLg2(b + ToBigInt(1));
        mutable result = ToBigInt(0);
        using (output = Qubit[na+nb]) {
            using (input1 = Qubit[na]) {
                using (input2 = Qubit[nb]) {
                    let v1 = LittleEndian(input1);
                    let v2 = LittleEndian(input2);
                    let v3 = LittleEndian(output);
                    XorEqualBigInt(v1, a);
                    XorEqualBigInt(v2, b);
                    PlusEqualProductUsingKaratsuba(v3, v1, v2);
                    XorEqualBigInt(v1, a);
                    XorEqualBigInt(v2, b);
                    set result = ForceMeasureResetBigInt(v3, a*b);
                }
            }
        }
        return result;
    }

    operation RunSchoolbookMultiplicationCircuit(a: BigInt, b: BigInt) : BigInt {
        let na = CeilBigLg2(a + ToBigInt(1));
        let nb = CeilBigLg2(b + ToBigInt(1));
        mutable result = ToBigInt(0);
        using (output = Qubit[na+nb]) {
            using (input1 = Qubit[na]) {
                using (input2 = Qubit[nb]) {
                    let v1 = LittleEndian(input1);
                    let v2 = LittleEndian(input2);
                    let v3 = LittleEndian(output);
                    XorEqualBigInt(v1, a);
                    XorEqualBigInt(v2, b);
                    PlusEqualProductUsingSchoolbook(v3, v1, v2);
                    XorEqualBigInt(v1, a);
                    XorEqualBigInt(v2, b);
                    set result = ForceMeasureResetBigInt(v3, a*b);
                }
            }
        }
        return result;
    }
}
