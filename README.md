single-page http server for x86\_64 linux in a 1kb static binary,
doesn't depend on libc

huge credits to @tleydxdy for bringing this down from 5kb to 1kb and
<1kb with the asm version

# build and run
```
./build.sh
./httpd 8080 test.html
```

if you don't have gcc, change build.sh to match your compiler

build even smaller asm version with a custom elf header, < 1kb

requires nasm

```
./asm.sh
./httpd 8080 test.html
```
