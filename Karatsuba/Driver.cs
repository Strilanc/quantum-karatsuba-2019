using System;
using System.Numerics;

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;

namespace Karatsuba {
    class Driver {
        static void Main(string[] args) {
            var qsim = new ToffoliSimulator();
            var tsim = new QCTraceSimulator();
            var rng = new Random(5);

            for (var i = 1; i <= 1024; i++) {
                var a = rng.NextBigInt(i);
                var b = rng.NextBigInt(i);
                var result = RunKaratsubaMultiplicationCircuit.Run(qsim, a, b).Result;
                Console.WriteLine($"{result == a*b}: {a}*{b} == {result}");
                // if (result != a * b) {
                //     throw new ArithmeticException($"Wrong result. {a}*{b} != {result}.");
                // }
            }
        }

    }

    static class Util {
        public static BigInteger NextBigInt(this Random rng, int bits){
            byte[] data = new byte[(bits >> 3) + 1];
            rng.NextBytes(data);
            var result = new BigInteger(data);
            result &= (BigInteger.One << bits) - 1;
            result |= BigInteger.One << (bits - 1);
            return result;
        }
    }
}