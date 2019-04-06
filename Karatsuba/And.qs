namespace Karatsuba {
    open Microsoft.Quantum.Extensions.Bitwise;
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;

    operation LetAnd(lvalue: Qubit, a: Qubit, b: Qubit) : Unit {
        body(...) {
            H(lvalue);
            T(lvalue);
            CNOT(b, lvalue);
            Adjoint T(lvalue);
            CNOT(a, lvalue);
            T(lvalue);
            CNOT(b, lvalue);
            Adjoint T(lvalue);
            H(lvalue);
            Adjoint S(lvalue);
        }
        adjoint (...) {
            if (MResetX(lvalue) == One) {
                CZ(a, b);
            }
        }
    }

    operation DelAnd(lvalue: Qubit, a: Qubit, b: Qubit) : Unit {
        body (...) {
            Adjoint LetAnd(lvalue, a, b);
        }
        adjoint auto;
    }
}
