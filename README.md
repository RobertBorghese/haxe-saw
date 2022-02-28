# Haxe (Snatched from Another World)
Haxe SAW (pronouced "hacksaw"), is a superset of Haxe that adds additional features with minor changes to the Haxe toolkit source code. It was obtained from an alternative universe where it was the standard version of Haxe.

---

### Shorthand Nullable Types

Based on Kotlin's nullable type syntax, adding a `?` to the end of a type is the equavalent of surronding with `Null<...>`.

```haxe
@:nullSafety(Strict) {
    var test: Int? = Math.random() < 0.5 ? 100 : null;
}
```

&nbsp;

### `if`/`while`/`for` No Parentheses

Based on Rust's and Swift's conditional/flow control, the parentheses surronding the inputs for flow control statements can be omitted.

```haxe
// valid
if Math.random() < 0.5 {
    trace("50% chance of seeing this");
}

// also valid
if Math.random() < 0.5 trace("50% chance of seeing this");

// for
for i in arr {
    trace(i);
}
```
