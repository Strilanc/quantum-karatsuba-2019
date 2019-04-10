# Reversible Karatsuba Multiplication Code (python)

## Testing

Run `pytest` from within the `karatsuba` directory.

## File layout

- `int_buffer.py`: Defines a mutable fixed-width unsigned integer class `IntBuf`,
with support for aliased slicing, padding, and concatenating.
- `util.py`: Miscellaneous utility methods such as `ceil_lg2`.
- `kara_square.py`: Squaring a number using reversible Karatsuba squaring.
    - `add_square_into`: Glue code to divide into words, pads words, delegates to the recursive construction.
    - `_add_square_into_pieces`: Recursive construction.
- `kara_mul.py`: Multiplying two numbers using reversible Karatsuba multiplication.
    - `add_product_into`: Glue code to divide into words, pads words, delegates to the recursive construction.
    - `_add_product_into_pieces`: Recursive construction.
