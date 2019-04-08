using System;
using System.Numerics;

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;

namespace Karatsuba {
    class Driver {
        static void Main(string[] args) {
            var rng = new Random(5);

            var collectTofCount = true;
            var collectQubitCount = true;

            var cases = new[] {32, 64, 512, 512+32, 1024, 1024+32, 2048, 2048+32, 4096+32};
            foreach (var i in cases) {
                var a = rng.NextBigInt(i);
                var b = rng.NextBigInt(i);
                var tof_sim = new ToffoliSimulator();
                var result = RunKaratsubaMultiplicationCircuit.Run(tof_sim, a, b).Result;

                var config = new QCTraceSimulatorConfiguration();
                config.usePrimitiveOperationsCounter = collectTofCount;
                config.useWidthCounter = collectQubitCount;
                var trace_sim = new QCTraceSimulator(config);
                var result2 = RunKaratsubaMultiplicationCircuit.Run(trace_sim, a, b).Result;
                if (result != a * b || result2 != result) {
                    throw new ArithmeticException($"Wrong result. {a}*{b} != {result}, {result==result2}.");
                }
                var csv = trace_sim.ToCSV();
                var tofCount = collectTofCount ? trace_sim.GetMetric<RunKaratsubaMultiplicationCircuit>(PrimitiveOperationsGroupsNames.T)/7 : -1;
                var qubitCount = collectQubitCount ? trace_sim.GetMetric<RunKaratsubaMultiplicationCircuit>(MetricsNames.WidthCounter.ExtraWidth) : -1;
                Console.WriteLine($"{i},{tofCount},{qubitCount}");
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