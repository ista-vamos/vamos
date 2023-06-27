# Sources

## Manually-written event sources

## Generated sources
### Specification language


```vamos
import file
import regex
import string

proc A {
  let f = file.reader($1);
  let t0 = new [Input, Output] out to proc B;
  let t1 = new [Input, Output] out to proc B;

  foreach line in f.lines() {
    let r = regex.search(line, "\s*(.)(.)\1(.)?");
    if r.matched() {
      let s = r.get(1);

      yield Input(s, string.concat(s, string.concat(s, s))) to t0;

      if r.has(3) {
        yield Output(r.get(3)) to t1;
      }
    }
  }
}

proc B {
}
```

#### Basic constructs

##### Let

`let` allows to bind objects **in the current namespace** to a name:

```vamos
let s = new [Input, Output];
let r = regex.match(line, "abc");
```

[TODO: name shadowing?]

##### New

- `new <type>` creates a new trace with a given type
- `new <type> name "N" out to X` creates a new trace with a given type and name `"N"`.
Name may be used to refer to the trace from other event source specifications.
`out to X` means that the trace is re-directed to `X` where `X`
may be  either another event source (in which case this trace becomes an input
to that source) or any object that has the `push` method. Such an object
is e.g., the `file.writer` object that writes the trace into a file.

#### End
- `end <trace>` explicitly notifies that a trace is finished.
- `end <trace> with $` explicitly notifies that a trace is finished and puts the
special event `$` marking the end of trace to the trace.


#### If

#### ForEach

#### EventLoop

ForEach iterates over an iterable continuously until the iterable has some
data.  It may not always be desired. To support event-driven programming while
avoid dangerous arbitrary mixing of synchronous and asynchronous statements, we
use an explicit `eventloop` specification which waits for a set of iterables to
finish and listens for their data. Similarly as for `foreach`, the
specification will stay in `eventloop` until all iterables are done (or it is
explicitly finished), but the data will be processed as they come to iterables,
in no specific order.
The callbacks are added with `on ... in` construct. New iterables can be added
to an event loop while running by nesting `on ... in`.

```vamos
eventloop {
  on <name> in <iterable> {
  }
}
```

An example:

```vamos
let l = dirs.listener($1, "new");
eventloop {
  on f in l.listen() {
    let nf = file.reader_listener(f);
    let t = new [Event];
    on line in nf {
       let r = regex.search("FIXME");
       if r.matched() {
         yield Event(line) to t;
       }
    }
  }
}
```
**TODO**: we must do **closures** for this so that we make sure the names
denote the right objects (`yield to t` must always use the right `t`,
not the last `t`).
#### Processes and IPC

TBD

#### Modules

The core specification language is rather small on its own, but it can be
extended with modules.  Modules are python objects that specify new methods and
language constructs and how to interpret them and compile them into other
languages. A module is imported to a specification with the keyword `import`.
As an example, take what happens in the following code:

```vamos
import random

let U = random.uniform(0, 10);

-- pick a random number from U
let x = pick from U;

-- yield a random event
yield Event(x ~ U, y ~ U);
```

The `import` statement imports the module `random` that makes available the
method `random.uniform` which creates an object that represents a random
variable with the unifrom distribution on numbers 0 .. 10.  But not only that.
The import also *adds new constructs to the language*.  The construct `pick
from` is not from the basic language and is added by the import. Similarly
creating the random event like `Event(x ~ U, y ~ U)` is a feature enabled by
the import.


When importing a module, the module specifies what methods it provides,
what modifications to the grammar are made (optional) and how to
interpret (compile) all the new methods and features.

