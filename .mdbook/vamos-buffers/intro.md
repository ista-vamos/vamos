# vamos-buffers

## Project structure

```
 - src/         # main source code
     - core       # implementation of buffers and streams (an abstraction over the buffers)
     - shmbuf     # creating buffers in the shared memory
     - streams    # auxiliary code for streams
 - include/     # public headers
 - python/      # python bindings (experimental)
 - cmake/       # cmake configuration files
 - tests/       # tests
```

## Configuring and building

A simple configuration, build, and runnning tests can be done with the
following commands:

```shell
$ cmake . -DCMAKE_C_COMPILER=clang
$ make -j4
$ make -j4 tests
```

Note that using clang is not compulsory, but some helper scripts in other VAMOS
repositories (e.g., `vamos-sources/tsan/compiler.py`) rely on that and there is
a risk that these scripts will not work in the release build if the library is
not compiled with clang. A work-around, if needed, is turning of
interprocedural optimizations (IPO) in cmake (use `-DENABLE_IPO=OFF` while
configuring).

## API documentation

TBD
