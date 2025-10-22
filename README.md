# xzutils_backdoor_obfuscation
This script recreates the obfuscation technique used for the XZ utils attack (CVE-2024-3094).
It has been tested for xzutils v5.6.0 only.

**This code is provided for educational purposes only.**

## Prerequisite
You must have the original `good-large_compressed.lzma` from  xzutils 5.6.0 in your working folder.

## Usage
Run the following
```./obfuscate_payload.sh [your_payload]```

A file `good-large_compressed.lzma` will be created, that must be placed in the folder `test/files` of the xzutils 5.6.0 source code.
The backdoor will then be extracted during the compilation process.

## Limitations
This code has been tested with an edited `liblzma_la-crc64-fast.o` of the same size as the original. Using a larger file may not work, as the payload size is limited
