## Mapping
[Virtual Machine Warmup Blows Hot and Cold](https://youtu.be/vLl4GteL9Mw)
[mmap man page](https://www.man7.org/linux/man-pages/man2/mmap.2.html)
[Rusty Runtimes: Building Languages In Rust](https://youtu.be/U3upi-y2pCk)
[Unsafe Rust](https://doc.rust-lang.org/nightly/book/ch19-01-unsafe-rust.html)

### Object encoding
The IEEE 754 64-bit binary number is encoded as follows:
	![IEEE 754 Binary-64](Pasted%20image%2020210311212924.png)

When the 11 mantissa bits are all 1s and at least one of the bottom 51 bits is non-zero, then the value is considered Not a Number (NaN), and the low 51 bits are otherwise ignored as a floating point number. Bit 51 should also be 1 to make a quiet (non-signaling) NaN.

So we have 52 bits to play with, as long as the number is non-zero. This lets us encode 2^52 possible values (see the comment at [SpiderMonkey](https://github.com/ricardoquesada/Spidermonkey/blob/4a75ea2543408bd1b2c515aa95901523eeef7858/js/src/gdb/mozilla/jsval.py)). They further point out that on many architectures only the bottom 48 bits are valid as memory addresses, and when used as such, the high 16 bits must be the same as bit 47.

There are several ways to do NaN tagging/encoding. You can choose integers, pointers, or doubles to be naturally encoded and all the others be encoded with some shifting/adding. While integers and pointers are probably more common in most Smalltalk images, leaving doubles as naturally encoded means that vector instructions and/or GPUs could act directly on memory.

So this leaves us with the following encoding based on the **S**ign+**M**antissa and **F**raction bits:

| S+M    | F    | F    | F    | Type                      |
| ------ | ---- | ---- | ---- | ------------------------- |
| 0000   | 0000 | 0000 | 0000 | double  +0                |
| 0000   | xxxx | xxxx | xxxx | double                    |
| 7FF7   | xxxx | xxxx | xxxx | double                    |
| 7FF0   | 0000 | 0000 | 0000 | +inf                       |
| 7FF8   | 0000 | 0000 | 0001 | NaN (generated)           |
| 7FF8   | xxxx | xxxx | xxxx | pointer                   |
| 7FF9-B | xxxx | xxxx | xxxx | NaN (unused)              |
| 7FFC/D | xxxx | xxxx | xxxx | negative integer   50-bit |
| 7FFE   | 0000 | 0000 | 0000 | integer   0               |
| 7FFE/F | xxxx | xxxx | xxxx | positive integer   50-bit |
| 8000   | 0000 | 0000 | 0000 | double     -0             |
| 8000   | xxxx | xxxx | xxxx | double                    |
| FFEF   | xxxx | xxxx | xxxx | double                    |
| FFF0   | 0000 | 0000 | 0000 | -inf                      |
| FFF8-F | xxxx | xxxx | xxxx | NaN (unused)              |

So, interpreted as an i64, any value that is less than or equal to the generated NaN value is a double. Else, if bit 50 is set, it's an integer and subtracting the integer 0 encoding will give the value. Else it's a pointer and subtracting the +inf encoding will give the value^[note that we don't encode 0 or 1 as pointer values].
