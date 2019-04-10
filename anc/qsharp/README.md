# Reversible Karatsuba Multiplication Code (Q#)

## Running Tests

Execute `dotnet test` inside the `Tests` directory.
Works best within Visual Studio Code.
Requires Q# to be installed.

## Collecting Stats

Using Visual Studio Code, execute `dotnet run` inside the `Karatsuba` directory.
(Modify `Driver.cs` to collect different stats.)
Works best within Visual Studio Code.
Requires Q# to be installed.

## File layout

- `Tests/*`: Unit tests.
- `Karatsuba/Addition.qs`: Implements `PlusEqual` that perform `a += b` using Cuccaro addition.
- `Karatsuba/And.qs`: Implements `LetAnd` and `DelAnd`.
- `Karatsuba/Xor.qs`: Implements `XorEqual` methods that perform `a ^= b`.
- `Karatsuba/Util.qs`: Implements miscellaneous methods such as `CeilBigLg2`, `MeasureBigInt`, etc.
- `Karatsuba/KaratsubaSquaring.qs`: Implements `PlusEqualSquareUsingKaratsuba` that performs `a += b*b`.
- `Karatsuba/Karatsubamultiplication.qs`: Implements `PlusEqualProductUsingKaratsuba` that performs `a += b*c`.
- `Karatsuba/Main.qs`: Glue code interfacing classical and quantum.
- `Karatsuba/Driver.cs`: Collects statistics.
