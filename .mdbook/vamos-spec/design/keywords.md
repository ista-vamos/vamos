# Keywords

```
in
out
var
let
if else
where
def
match
foreach
forall
exist
select
iter
```

### in, out

```
in [stream]
out [stream]

foreach [x] in [iterable]

out trace  -- output a trace in a hypertrace transformer
```

### let, var

```
let x [: type] = [expr];
var y [: type] [= expr];
```

`let` binds an immutable reference, a name of a value.
`var` defines a new variable that can be modified.

### if-else

```
if [bool] {expr} [else {expr}]?

let y = if c {3} else {5};
```


### iter

```
transform [name]* [-> [name*]] { rule+ }
```

Iteratively match rules on a trace or several traces. All traces that are in the local scope can be matched
or a list of allowed traces to match is used. The matching ends if matching fails,
or the matching is explicitely terminated, or all traces are entirely read (that is why we can explicitely specify
what traces we can iterate through -- there might be more traces in the local scope than we want to use).
In the latter case, if there is a rule that matches ("consumes") the end of traces is evaluated before finishing matching.

Rules can be nested inside `if-else` expressions.


### forall, exist, select

For specifying traces in a hypertraces. forall is clear, exist = select limit 1. Select is like forall but can
apply only a limited number of traces and maybe some more things?
