# Compiler

VAMOS has several compilers that generate code and monitors for different use cases.

### vamos-compiler

One compiler is `vamosc` in the repository
[vamos-compiler](https://github.com/ista-vamos/vamos-compiler).  This compiler
takes a description how to transform multiple input streams into a single
output stream that can be analyzed either by an external monitor or by a
monitor written in the same specification language as the transformation.

Publication: [VAMOS: Middleware for Best-Effort Third-Party Monitoring](https://link.springer.com/chapter/10.1007/978-3-031-30826-0_15)

### vamos-mpt

Compile a specification of a multi-trace prefix transducer into C++ code.
There is a work-in-progress to generate code that attaches the MPTs to
vamos sources. One can always write the code to attach to the sources by hand
at this moment. The compiler is in the repository
[vamos-mpt](https://github.com/ista-vamos/vamos-mpt)

### [WIP] vamos-spec/vamos-hyper

We have a work-in-progress language for specification of hypertrace transformations.
One can see `vamos-mpt` as its simplified version.
