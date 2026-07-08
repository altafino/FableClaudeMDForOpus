<!-- guardrails-kit: v1.1 | Rows verified against Go 1.26-era spec/docs, 2026-07-08. Editing this file? Read docs/guardrails/_FORMAT.md first. Never paraphrase kit text. -->
You are here because CODE.md C7 pack dispatch fired: go.mod is present and you are editing a .go file. Find your rows; no row covers a load-bearing behavior? Probe with `go run` and paste the output — never guess.

## Nil, errors, interfaces
- A typed nil pointer stored in an interface makes `err != nil` TRUE -> return literal nil, never a nil *ConcreteError.
- Wrap errors with %w (errors.Is/As keep working); %v breaks the chain — choose deliberately and say which.

## Slices & maps
- Subslices share the backing array: append through one can overwrite the other -> full-slice expression `s[low:high:max]` or `slices.Clone` before divergent writes.
- append may or may not reallocate — rely on neither; state ownership in a comment when a slice crosses a function boundary.
- Writes to a nil map panic (reads do not) -> make the map first. Iteration order is random -> sort keys when order matters. Concurrent map access is fatal -> mutex or sync.Map.

## Defer, goroutines, channels
- defer arguments evaluate AT THE DEFER LINE; the call runs at function exit; defers in loops pile up -> wrap the loop body in a func.
- Every goroutine names its exit condition in a comment (context cancel, channel close) — no named exit is a leak.
- Send on a closed channel panics; receive from closed returns the zero value immediately; a nil channel blocks forever -> state which case each op can hit.
- Version rows: <1.22 loop variables are captured by reference (`i := i` required); <1.23 `time.After` inside loops leaks timers.

## Encoding & numbers
- encoding/json drops unexported fields SILENTLY; `omitempty` also hides 0, false, "" (zero is data — CLAUDE.md iron rule 9).
- int64 IDs above 2^53 corrupt through JS consumers -> transport as strings.
- Copying a struct that contains a sync.Mutex copies the lock -> pass pointers; run `go vet` and paste its result.
