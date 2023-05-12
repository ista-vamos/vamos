# Examples

```vamos
Event valX;
Event valY;
Event valZ { x: Int32 }

Trace Observations = [valX, valY, valZ, mode: {x: Int8}];

in observations : {Observations ...};
out compl(observations) : {Accesses};

def compl {
  in T: {Observations, Accesses ...};
  out O: {Accesses ...};

  forall t in T where t[0] == Observations::mode(1) {
    forall t2, t3 in T where t2 != t && t2[0] == t[0] {
      transform t, t2, t3 -> t4, t5 {
        t: a,
        t2: a valX,
        t3: b valZ(x)
        where x > 0 {
          yield valX to t4;
          yield valX to t5;
        }

        t: a, t2: b { yield a; }
      }

      out t, t4, t5;
      out (compl2.compl1)(t, compl(t4,t5));
    }
  }
}

```

```vamos
Event valX;
Event valY;
Event valZ;
Event mode1, mode2 { x: Int8 }

Data valZ { x: Int32};
Data valZ, valX { x: Int32};

Trace Observations = [valX: {}, valY:{}, valZ:{}, mode: {x: Int8}, mode1 ];

in observations : {Observations};
out (Order . compl)(observations) : {Accesses};

def compl {
  in T: {Observations};

  forall t in traces where t[0] == mode(1, 2) {
    forall t2, t3 in traces where t2 != t && t2[0] == t[0] {
      transform t, t2, t3 -> t4, t5 {
        t: a,
        t2: a valX {
          yield valX to t4;
        }
      }

      transform t -> t {
        t: b { yield c; }
        if same > 0 {
          t: a where same == 0 { yield r; }
          t: a where x { yield r; }
        }
      }

      out t;
      out t4, t5;
    }
  }
}

-- select t, t2, t3
--   from traces, (select x, y from traces where x != t && y[0] == t[0] limit 1)
-- forall t in traces where t[0] == mode(1) {
  -- exist t2, t3 in traces where t2 != t && t2[0] == t[0]
   -- select t2, t3 from traces where t2 != t && t2[0] == t[0] limit 1
   -- && iter t2, t3 {
   --   t2 ~ m@{_ * valX}, t3 ~ n@{_* valX} where m == n
   -- }


-- def Order {
--   in T: {Accesses};
--   out O1, O2: {Accesses};
--
--   -- take a hyper trace, transform it into another hyper trace (for the next
--   -- step) and an output element of the new hyper(trace)
--   htransform T -> F, G {
--      let t = first 3 from T as x, y, z
--              where x[0] ~ input(2);
--      foreach e in t[0] {
--         push e;
--      }
--
--      foreach e in T[0] {
--        if e ~ input(x) {
--          push e;
--          -- what if I want to split the stream?
--          -- and access the split streams later?
--
--          -- push e to hypertrace T to trace of the same id as trace(e)
--          push e to O1.;
--          -- push e to (possibly new) hypertrace T with "id" n
--          push e to T.n;
--        }
--        consume e; -- from which trace??
--      }
--      yield;
--   }
-- }

```

```vamos
Trace trace = [input: {val: Int32},
               update: {val: Int32},
               action: {}];

in traces: {Trace};
out monitor(traces);

def od(pi: Trace, pi': Trace) -> Bool {
  var same : Bool = false;

  transform pi, pi' -> () {
    pi:  _* update(val)  | ,
    pi': _* update(val2) | where same {
       if val != val2 {
          error "Observational determinism violated";
       }
    }

    pi:  _* input(val) |,
    pi': _* input(val) | {
        same = true;
    }
  }
}

def monitor(traces: {Trace}) -> Bool {
  forall t1, t2 in traces {
    od(t1, t2);
  }
}


def monitor2(traces: {Trace}) -> Bool {
  forall t1, t2 in traces {
    if !od(t1, t2) {
      return false;
    }
  }

  return true;
}
```

```vamos
import sha256;

Event input, output { x: UInt64 }
Event other;

Event IOPair {
  i: UInt64;
  o: UInt64;
}

Trace trace = [input, output, other];

in traces : {trace ...};

def split {
  in traces : {trace ...};

  forall t in traces {   -- SELECT t FROM traces
    transform t -> ti, to {
      t: ev {
        match ev with {
          input  => yield ev to ti;
          output => yield ev to to;
        }
      }
    }

    transform ti, to -> pi {
      var mdI = sha256.create();
      var mdO = sha256.create();

      ti: input(x)  { mdI.update(x); }
      to: output(x) { mdO.update(x); }
      ti, to: $ {
          yield IOPair(mdO.get(), mdI.get()) to pi;
      }
    }
    out pi;
  }
}

def monitor(iotrace) {
  in iotrace: [IOPair];
  var iomap: Map[UInt64, UInt64];

  transform iotrace -> () {
    iotrace: IOPair(i, o) {
      if iomap.has(i) {
        if iomap.get(i) != o {
          error("OD violated");
        }
      } else {
        iomap.insert(i, o);
      }
    }
  }
}
```

```vamos
Event valX, valY, valZ {
    x: Int32
}

Event mode {
    m: Int32
}

Trace Observations [valX, valY, valZ] {}

in traces: {Observations};

out (Monitor . ModesSwitch . StutterReduce)(traces)

def sred: Observations -> Observations {
  in t: Observations;

  iter t {
    t: e e* | !e {
      yield e;
    }
  }
}

def StutterReduce : {Observations} -> {Observations} {
  in traces: {Observations};

  forall t in traces {
    out sred(t);
  }
}

-- filter events based on mode
def modesw(t: Observations) -> Observations {
  var mode : Int32 = 0;

  transform t {
    t: e@mode(x) {
      mode = x;
      yield e;
    }

    t: e where mode == 0 {
      yield e;
    }

    if mode > 0 {
      t: valX where mode == 2 {
        yield e;
      }

      t: valY where mode in (1, 2) {
        yield e;
      }

      t: valZ where mode == 3 {
        yield e;
      }
    }
  }
}

-- same as `foreach t in INPUT { out modesw(t); }`
let ModesSwitch = hlift(modesw);

-- automatically takes as input the outputs of the traces/model generator
def Monitor(traces) {
  foreach t1, t2 in traces where t1[^0] == t2[^0] {
    iter {
      t1 ~ a@_#[0..] mode(x)#[2..4] |,
      t2 ~ b@_* mode(y) |
      {
         if t1[a] != t2[b] {
                 error "Observational determinism violated"
         }
      }
    }
  }
}

```

```vamos
Stream Trace : [input: {val: Int32;},
                update: {val: Int32;}] {
}

in traces: {Trace};
out monitor(traces);


def suff(pi: Trace, pi': Trace) -> {Trace} {
  # output sequences from the traces that start with the same
  # input util theres another input
  forall m1@{input(val) _* {input + $}} in pi,
         m2@{input(val) _* {input + $}} in pi' {
    out(zipd(pi[m1-1], pi'[m2-1], nil));
  }
}


def monitor(traces) {
    forall t1, t2 in traces.
    forall s in suff(t1, t2).
    forall x in s. x_0 == x_1
}

-- pi:  i(3) u(2) u(1) i(2) u(2) u(1)
-- pi': i(2) u(2) u(1) i(2) u(2)
-- -----------------------------------
--
-- out_1: (i(2), i(2)) (u(2), u(2)) (u(1), u(1))
-- out_2: (i(2), i(2)) (u(2), u(2)) (u(1), nil)

```
