using Microsoft.Quantum.Simulation.XUnit;
using Microsoft.Quantum.Simulation.Simulators;
using Xunit.Abstractions;
using System;
using System.Diagnostics;

namespace Tests {
    public class TestSuiteRunner {
        private readonly ITestOutputHelper output;

        public TestSuiteRunner(ITestOutputHelper output) {
            this.output = output;
        }

        [OperationDriver(TestNamespace = "Tests")]
        public void TestTarget(TestOperation op)
        {
            Console.WriteLine(op.className);
            if (op.className.Contains("ToffoliSim")) {
                var sim = new ToffoliSimulator();
                sim.OnLog += (msg) => { output.WriteLine(msg); };
                sim.OnLog += (msg) => { Debug.WriteLine(msg); };
                op.TestOperationRunner(sim);
            } else {
                using (var sim = new QuantumSimulator()) {
                    sim.OnLog += (msg) => { output.WriteLine(msg); };
                    sim.OnLog += (msg) => { Debug.WriteLine(msg); };
                    op.TestOperationRunner(sim);
                }
            }
        }
    }
}
