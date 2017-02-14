# The NuummiteOS heap

The new NuummiteOS heap is a pretty complex thing.   
This document will describe in detail how it works.

NOTE: This document is NOT finished yet. Expect things to change.

## Memory chunks

Memory chunks are managed through blocks.   
A block consists of a header and a pointer to the usable memory.

### The block

The following describes the block layout in detail:

| Offset (32-bit) | Offset (64-bit) | Value        |
| --------------- | --------------- | ------------ |
| 00 (0x00)       | 00 (0x00)       | Header       |
| 12 (0x0C)       | 24 (0x18)       | Memory chunk |

### The header

The header encodes the state of the block and additional metadata.   
The following describes the header layout in detail:

| Offset (32-bit) | Offset (64-bit) | Value              |
| --------------- | --------------- | ------------------ |
| 00 (0x00)       | 00 (0x00)       | Magic              |
| 04 (0x04)       | 08 (0x08)       | Block size         |
| 08 (0x08)       | 16 (0x10)       | Next block pointer |

Or, in a more traditional way:

```
Offset (32-bit): 0         4        8             12
Layout         : |  Magic  |  Size  |  NextBlock  |
Offset (64-bit): 0         8        16            24
```

#### The magic value

The `Magic` value contains specific bit patterns that allow the   
verification and validation of blocks, and it also encodes special   
flags that hold extra information about the block.

The following describes the magic value in detail.   
Each byte of the magic value is always a safety + flag pair.

Safety bits are fixed bits with a known value which are used to validate the block.   
If any of those bits are overridden, the block becomes invalid.

Flag bits are variable bits which are used to encode extra information.

Terminology:   
`S` = 4 safety bits   
`F` = 4 flag bits   

| Offset    | Byte layout | 64-bit only |
| --------- | ----------- | ----------- |
| 00 (0x00) | SF SF FS FS | no          |
| 04 (0x04) | FS FS SF SF | yes         |

Or, again, in a more traditional way:

```
Offset (32-bit): 0      1      2      3      4
Layout (32-bit): |  SF  |  SF  |  FS  |  FS  |
Layout (64-bit): |  SF  |  SF  |  FS  |  FS  |  FS  |  FS  |  SF  |  SF  |
Offset (64-bit): 0      1      2      3      4      5      6      7      8
```

Flags are applied by just filling the flag bits with the flag value.   
The following is a list of all valid flags:

```ruby
Init = 0      = 0x0 # The initial state
Used = 1 << 0 = 0x1 # The block is used
GCSh = 1 << 1 = 0x2 # GC scheduled
```