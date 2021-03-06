## Image format
The image format contains no compiled code. It is output after a full garbage collection, and contains the heap (which begins with a special header), followed by the class table and the symbol table.

| Name    | Value                 | Description                             |
| ------- | --------------------- | --------------------------------------- |
| Header  | 0x0102030405415354    | Tag establishing endianness followed by AST |
|         | heapSize              | Size of the heap in 64-bit words        |
| Heap    | heapSize 64-bit words | the complete heap                       |
|         | nClasses              | number of classes in the class table    |
| Classes | nClasses 64-bit words | addresses in the heap of the classes    |
|         | nSymbols              | number of symbols in the symbol table   |
| Symbols | nSymbols  names       | 16-bit n, followed by n bytes; n=0 for skipped symbols                 |

### Loading the image
Loading looks like:
1. The image (including header) is read into memory at address 0x1000000000 (64GB).
2. Then the endianness of the image is determined. In theory the image can be corrected to the current endianness, but for now it will simply fail.
3. Then any supporting heaps are created.
4. Then the dispatch table (with empty dispatchers) and symbol table are created.
5. Then the message `start` is sent to the class `System`.
6. Execution is initially entirely AST interpretation, but once the compiler has been registered, it will be called for missing methods to build up proper dispatchers.

### Saving the image
To save the image:
1. all threads send the message `stop` to the class `System`, then exit.
2. garbage collection is done until the heap is at address 0x1000000010 (this may require 2 rounds of full GC)
3. the heapSize field of the image header is updated
4. the header and heap are written to the file
5. the classes table is written
6. the symbols list is written

