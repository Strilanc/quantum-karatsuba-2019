// namespace Tests {
//     open Microsoft.Quantum.Primitive;
//     open Microsoft.Quantum.Canon;
//     open Microsoft.Quantum.Extensions.Convert;
//     open Microsoft.Quantum.Extensions.Diagnostics;
//     open Karatsuba;

//     operation CheckMul(k1: Int, k2: Int, k3: Int, a1: BigInt, a2: BigInt, a3: BigInt) : Unit {
//         Message($"CheckMul({k1}, {k2}, {k3}, {a1}*{a2}+{a3})");
//         using (q1 = Qubit[k1]) {
//             using (q2 = Qubit[k2]) {
//                 using (q3 = Qubit[k3]) {
//                     let n1 = LittleEndian(q1);
//                     let n2 = LittleEndian(q2);
//                     let n3 = LittleEndian(q3);
//                     XorEqualBigInt(n1, a1);
//                     XorEqualBigInt(n2, a2);
//                     XorEqualBigInt(n3, a3);
//                     PlusEqualProductUsingKaratsuba(n3, n1, n2);
//                     let e1 = MeasureResetBigInt(n1);
//                     let e2 = MeasureResetBigInt(n2);
//                     let e3 = MeasureResetBigInt(n3);
//                     if (e1 != a1) {
//                         fail $"Input 1 mangled: {e1} != {a1}";
//                     }
//                     if (e2 != a2) {
//                         fail $"Input 2 mangled: {e2} != {a2}";
//                     }
//                     if (e3 != (a3 + a1 * a2) % (ToBigInt(1) <<< k3)) {
//                         fail $"Wrong result: {e3} != ({a3} + {a1} * {a2}) % (1 << {k3})";
//                     }
//                 }
//             }
//         }
//     }

//     operation ToffoliSim_PlusEqualProductUsingKaratsuba_Test () : Unit {
//         CheckMul(42, 42, 91,
//             BoolsToBigInt([false,false,true,true,false,false,false,false,false,true,false,false,true,false,true,true,false,false,true,true,true,true,true,true,false,false,true,false,true,true,true,false,true,true,true,true,true,true,true,true,false,true,false]),
//             BoolsToBigInt([false,true,false,false,true,false,false,false,true,false,false,true,true,false,false,true,true,false,true,true,false,false,false,false,true,false,false,false,true,true,true,true,true,true,false,true,false,false,false,true,true,true,false]),
//             BoolsToBigInt([false,false,true,true,false,false,false,false,true,true,false,false,false,true,true,true,false,false,true,false,false,false,false,true,false,true,false,false,true,true,true,false,false,false,true,false,true,false,false,false,true,true,false,true,false,false,false,true,true,true,false,true,true,true,false,true,false,true,true,true,false,true,false,true,true,false,false,true,false,true,false,true,true,true,false,true,false,false,false,false,true,false,true,false,false,false,false,true,false,true,true,false]));
//         CheckMul(57, 65, 47,
//             BoolsToBigInt([true,true,false,true,true,false,true,true,true,true,true,false,false,false,true,true,true,false,false,true,false,true,false,false,false,true,true,true,true,true,false,true,false,false,false,true,false,false,true,false,true,false,false,true,false,false,true,false,true,false,true,false,false,true,false,true,false]),
//             BoolsToBigInt([true,false,true,true,false,false,true,true,false,false,true,false,false,false,true,false,true,false,true,false,true,true,false,false,false,false,true,true,true,false,false,false,true,false,false,true,true,false,false,false,false,false,true,true,true,true,false,false,false,false,true,true,true,true,false,false,false,true,true,false,true,false,false,true,false]),
//             BoolsToBigInt([false,true,false,true,true,true,true,true,true,false,false,true,false,true,false,false,true,true,true,true,true,false,true,false,false,true,true,true,true,false,false,false,true,true,true,true,true,false,true,true,false,false,false,false,true,true,false]));
//         CheckMul(87, 47, 64,
//             BoolsToBigInt([true,true,false,false,true,true,false,true,false,true,true,true,true,false,false,true,false,true,false,false,false,true,false,false,true,true,false,true,false,false,true,true,true,true,false,false,true,true,true,false,false,true,true,false,false,false,true,false,false,true,true,true,false,true,false,true,false,false,false,false,true,true,false,false,true,true,true,false,false,true,false,true,false,true,true,false,true,true,true,true,false,true,false,false,true,true,true,false]),
//             BoolsToBigInt([false,false,false,true,true,false,true,false,false,false,false,true,false,false,true,true,false,true,false,false,false,false,false,true,true,true,true,false,false,true,true,false,false,true,true,true,false,false,false,true,true,false,true,false,false,true,true,false]),
//             BoolsToBigInt([false,false,true,true,true,true,false,false,false,false,false,true,false,false,true,false,false,false,false,true,true,false,false,true,true,true,true,true,false,true,false,false,true,true,false,false,true,false,false,true,true,true,false,false,true,true,true,true,true,false,true,true,false,false,false,true,false,false,true,false,false,false,true,true,false]));
//         CheckMul(66, 18, 44,
//             BoolsToBigInt([true,true,true,false,true,false,false,false,false,true,true,false,false,false,false,true,false,true,false,false,true,true,false,true,true,true,true,false,false,true,true,false,true,true,true,false,false,false,true,true,false,true,false,false,false,true,false,true,true,false,false,false,true,true,false,false,true,false,false,false,false,false,true,true,true,false]),
//             BoolsToBigInt([false,false,false,true,true,false,false,false,false,true,false,true,false,false,false,true,false]),
//             BoolsToBigInt([false,true,true,false,false,true,false,true,true,true,false,true,false,false,true,true,true,true,true,true,false,false,false,false,true,true,true,true,true,false,false,true,true,true,false,true,true,true,false,true,false,true,false]));
//         CheckMul(66, 24, 140,
//             BoolsToBigInt([false,true,false,true,false,false,false,true,false,true,false,true,false,false,true,true,true,true,true,false,false,true,true,false,true,false,true,false,true,true,true,false,true,true,false,false,true,true,false,false,false,false,true,true,true,true,true,true,false,true,true,false,true,true,false,true,false,false,false,true,false,true,false,true,true,true,false]),
//             BoolsToBigInt([false,true,false,false,false,true,false,true,true,false,true,false,false,true,false,false,true,true,false,true,true,false]),
//             BoolsToBigInt([false,true,true,true,true,false,true,false,false,true,false,false,false,false,false,true,true,false,false,false,true,true,true,true,true,false,true,true,true,false,false,true,true,false,true,true,false,false,false,true,true,true,true,false,false,false,true,false,false,false,true,true,false,false,false,true,false,true,true,false,false,true,true,true,true,false,true,true,true,false,false,false,true,false,true,false,false,false,false,true,true,false,false,false,true,true,true,true,false,true,true,false,true,false,true,true,false,true,false,false,true,true,false,false,false,true,false,false,false,false,false,false,true,false,true,true,false,false,false,false,false,true,false,false,true,true,true,false,false,false,true,true,false,true,false,true,true,false,true,true,false]));
//         CheckMul(85, 12, 24,
//             BoolsToBigInt([true,true,true,false,false,true,true,true,false,true,false,false,true,true,false,false,false,true,true,true,false,false,true,true,true,false,false,true,false,false,false,true,true,false,true,false,true,true,true,false,false,false,false,false,true,false,false,false,false,true,true,false,true,false,false,false,false,true,true,false,false,true,false,false,false,true,false,true,false,false,true,true,true,true,false,false,false,false,false,false,true,false,false,true,false]),
//             BoolsToBigInt([false,true,false,true,false,true,false,true,true,true,true,false]),
//             BoolsToBigInt([true,true,true,false,true,true,true,true,false,false,false,true,false,false,false,false,true,false,false,true,false]));
//         CheckMul(24, 24, 114,
//             BoolsToBigInt([false,true,false,false,false,false,true,false,true,true,true,true,false,true,false,false,true,false,false,true,true,false,true,false]),
//             BoolsToBigInt([true,false,false,true,true,true,true,false,true,true,true,false,true,false,false,true,false,false,true,true,true,false]),
//             BoolsToBigInt([true,false,true,true,true,true,false,false,true,true,true,true,false,true,false,false,true,false,false,false,true,false,true,false,false,true,true,true,true,false,true,false,true,true,true,false,false,true,true,true,false,false,false,true,true,true,false,false,true,false,false,true,false,true,true,true,false,true,true,false,false,false,true,true,true,false,true,false,false,false,false,true,true,true,false,true,true,true,true,true,false,false,true,true,true,true,false,false,true,true,false,true,false,false,true,false,true,false,false,false,true,true,true,true,true,false,true,false,true,false,false,true,false,true,false]));
//         CheckMul(90, 60, 147,
//             BoolsToBigInt([true,false,true,true,true,false,false,false,false,true,false,false,false,true,true,true,false,true,false,true,true,false,true,true,false,true,true,true,false,false,false,true,true,false,true,true,true,false,false,true,false,true,true,false,true,false,false,true,true,false,false,true,true,false,false,true,false,true,true,true,false,true,false,true,true,true,true,true,true,true,false,false,false,true,true,true,false,true,true,true,true,false,true,false,true,false]),
//             BoolsToBigInt([false,false,false,true,true,false,false,true,true,false,false,true,false,true,true,true,true,false,false,false,false,true,false,true,true,true,true,true,true,true,true,false,false,true,true,true,true,true,true,false,true,false,true,true,false,true,true,false,true,false,false,false,true,false,false,true,false,true,true,false]),
//             BoolsToBigInt([false,false,true,false,true,false,true,false,false,false,true,false,true,false,true,true,true,false,true,false,true,false,true,false,true,true,true,true,false,true,true,true,true,true,true,false,true,true,false,false,true,false,false,true,false,false,false,false,false,false,false,true,false,true,false,false,true,true,false,true,false,true,false,true,false,false,true,true,false,true,true,false,true,true,true,false,false,true,false,false,false,false,false,true,false,false,false,true,true,true,false,false,false,true,true,true,true,false,false,false,true,true,false,false,false,true,true,false,true,true,true,true,true,false,true,false,false,true,false,true,true,false,false,false,true,true,false,true,true,true,true,true,true,false,true,true,true,true,true,true,false,true,false,false,true,false]));
//         CheckMul(89, 14, 146,
//             BoolsToBigInt([false,false,false,false,false,false,false,false,false,true,false,false,false,false,true,true,true,true,true,true,false,false,true,false,false,true,false,false,true,true,true,false,false,true,false,false,false,false,true,false,true,false,true,false,true,true,false,false,false,false,true,false,true,false,true,true,false,false,true,false,true,false,false,true,false,true,true,true,true,true,false,true,true,false,true,true,false,true,false,false,false,false,false,false,false,false,true,true,false]),
//             BoolsToBigInt([false,false,true,false,true,true,false,true,false,true,false]),
//             BoolsToBigInt([false,false,true,true,true,false,false,true,true,false,true,true,false,true,true,false,false,false,false,true,true,false,false,true,true,false,true,false,false,false,false,true,false,false,false,true,true,false,true,true,false,false,true,false,true,false,false,true,true,false,false,true,false,true,false,false,true,true,false,false,false,true,true,false,true,false,true,false,true,false,false,true,true,true,false,false,false,false,false,true,true,true,false,false,true,false,false,false,true,false,false,true,false,false,false,true,false,true,true,true,true,false,false,false,true,true,true,true,false,false,true,true,true,true,false,true,false,false,true,true,true,true,false,true,true,false,true,true,true,false,false,false,true,false,false,true,false,true,false,false,false,false,true,false,true,true,false]));
//         CheckMul(27, 82, 139,
//             BoolsToBigInt([true,true,false,false,true,true,false,true,false,false,false,false,false,true,false,false,false,true,true,true,true,false,false,false,true,false]),
//             BoolsToBigInt([false,true,false,false,false,false,false,false,false,false,true,false,false,false,true,false,false,true,false,true,true,false,true,false,true,false,true,true,false,false,false,true,true,false,false,false,false,true,false,true,true,true,false,true,false,true,true,true,false,true,true,false,false,false,false,false,false,false,false,true,true,false,true,false,false,true,false,false,false,true,false,true,false,false,true,true,false,false,true,true,false,true,false]),
//             BoolsToBigInt([true,true,false,false,false,true,false,true,true,false,false,true,false,true,true,false,true,false,true,true,true,true,false,false,false,true,false,false,false,false,false,false,false,false,true,false,false,false,true,true,true,false,true,false,false,true,true,true,false,false,false,true,true,true,true,false,false,true,true,false,false,false,false,false,true,false,false,true,true,true,true,false,true,false,true,false,true,false,true,false,true,true,false,true,false,true,false,true,false,true,true,false,true,true,true,true,false,true,false,false,true,true,false,false,false,true,true,false,true,false,false,true,false,false,false,true,true,true,false,false,true,false,false,false,true,true,false,true,true,false,true,true,true,true,false,false,true,true,false]));
//         CheckMul(35, 12, 88,
//             BoolsToBigInt([true,true,false,true,false,true,true,false,true,false,false,false,true,false,false,true,false,true,false,false,true,true,true,false,true,false,true,true,true,true,false,false,false,true,true,false]),
//             BoolsToBigInt([false,false,true,true,true,false,false,false,true,true,false,true,false]),
//             BoolsToBigInt([false,false,false,true,false,false,false,true,true,false,true,true,true,true,false,true,true,false,false,true,true,true,true,false,true,true,false,false,true,true,false,false,false,true,false,true,false,false,true,false,true,true,false,true,true,true,true,true,true,true,false,false,false,true,false,false,true,false,true,false,true,true,false,true,false,false,false,false,true,false,false,false,false,true,true,true,true,true,false,true,true,true,true,false,false,true,false]));
//         CheckMul(84, 68, 94,
//             BoolsToBigInt([true,false,false,false,false,false,true,true,true,false,true,true,false,true,true,true,false,false,true,false,true,false,false,false,false,true,false,true,false,true,true,true,false,true,false,true,false,false,true,true,true,false,false,false,true,false,false,true,false,false,true,true,false,true,true,true,true,false,true,true,true,true,true,true,false,true,false,false,false,true,false,true,true,true,false,false,false,false,true,false,false,true,true,false]),
//             BoolsToBigInt([true,false,false,false,false,true,true,false,false,false,false,true,true,true,true,true,true,true,false,false,true,true,true,true,false,true,false,true,false,false,true,true,false,false,true,true,false,false,true,true,true,true,false,true,false,false,false,false,false,true,true,false,false,true,false,false,true,false,false,true,true,true,true,true,true,false,true,false]),
//             BoolsToBigInt([false,false,false,true,false,false,false,false,false,true,false,false,true,false,false,true,false,false,true,true,false,false,true,true,true,true,true,false,false,true,false,true,false,false,false,false,true,false,false,true,false,false,true,true,false,true,false,false,true,true,false,false,false,true,true,true,true,true,false,false,false,true,false,false,false,true,false,true,true,true,false,false,true,true,false,false,true,true,false,false,true,false,true,false,true,false,false,true,true,false,false,true,false,true,false]));
//     }
// }
