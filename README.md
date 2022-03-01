# Haxe (Snatched from Another World)
Haxe SAW (pronouced "hacksaw"), is a superset of Haxe that adds additional features with minor changes to the Haxe toolkit source code. It was obtained from an alternative universe where it was the standard version of Haxe.

In all seriousness, this is a fork of Haxe created primarily for personal use. The provided features are extremely opinionated, and they are only added due to the (near) impossibility of them being implemented into the official Haxe compiler because of their redundancy, absurdity, or explicit denial from Haxe developers.

Also, please note I have no experience in OCaml outside of modifying the Haxe compiler, so there are no guarentees I know what the hell I'm doing... just in case you actually look at the source code.

---

To learn more about Haxe, visit:\
[Official Haxe Github](https://github.com/HaxeFoundation/haxe)\
[Official Haxe Website](https://haxe.org/)\
[Official Haxe Download](https://haxe.org/download/)

---

# [Installation]

1) Download like you would with any version of Haxe from Releases or build it yourself.
2) Add it to PC PATH if necessary.
3) And/or if you're using Visual Studio Code add `"haxe.executable"` to your `settings.json` with the location HaxeSAW haxe.exe as the value.

---
# [Features]

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

&nbsp;

### `fn` Keyword

Based on Rust's function keyword. Can be used as a replacement for `function` in almost all cases.

```haxe
fn test() {
	trace("do thing");
}

fn main() {
	// fn can still be used as variable name for compatibility
	var fn = () -> {
		trace("i am smol");
	};

	// as a result, it can't be used as a value.
	// use lambdas for small function syntax instead
	var fn2 = fn() { // invalid
		trace("so am i");
	}
}
```
