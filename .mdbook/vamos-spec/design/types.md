# Types

## Primitive types

```
Bool
Int{8, 16, 32, 64}
UInt{8, 16, 32, 64}
Float{32, 64}
Void
```

## Composite types

### Struct types

```
Data
Event
```

BasicSubtype ::= PrimitiveType | StructType

### Sequential types

```
Vector
String

Stream[BasicSubtype+]
```


MappableType ::= PrimitiveType | StructType | SequentialType

### Collection types

```
Map[BasicSubtype, Type]
Set[Type]
```

### Special types

```
Trace[BasicSubtype+]
HyperTrace[TraceType+]
View[Type]
IndexedView[Type]
```

We strictly differentiate between streams and traces. Stream is a sequence of events or data points,
a trace is a logical object that represents such a sequence.
The main difference is that iteration over a stream means iterating over a sequence
and thus the generated program takes one element after another.
For traces, we can only specify what to do for all elements and thus the generated program
will lazily and incrementally evaluate the specification over the trace.
