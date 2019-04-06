﻿using Microsoft.Quantum.Simulation.XUnit;
using Microsoft.Quantum.Simulation.Simulators;
using Xunit.Abstractions;
using System.Diagnostics;

namespace Tests
{
    public class TestSuiteRunner
    {
        private readonly ITestOutputHelper output;

        public TestSuiteRunner(ITestOutputHelper output)
        {
            this.output = output;
        }

        /// <summary>
        /// This driver will run all Q# tests (operations named "...Test") 
        /// that belong to namespace Tests.
        ///
        /// To execute your tests, just type "dotnet test" from the command line.
        /// </summary>
        [OperationDriver(TestNamespace = "Tests")]
        public void TestTarget(TestOperation op)
        {
            using (var sim = new QuantumSimulator())
            {
                // OnLog defines action(s) performed when Q# test calls function Message
                sim.OnLog += (msg) => { output.WriteLine(msg); };
                sim.OnLog += (msg) => { Debug.WriteLine(msg); };
                op.TestOperationRunner(sim);
            }
        }
    }
}
