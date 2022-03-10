# Haxe (Snatched from Another World)
Haxe SAW (pronouced "hacksaw"), is a superset of Haxe that adds additional features with minor changes to the Haxe toolkit source code. It was obtained from an alternative universe where it was the standard version of Haxe.

In all seriousness, this is a fork of Haxe created primarily for personal use. The provided features are extremely opinionated, and they are only added due to the (near) impossibility of them being implemented into the official Haxe compiler because of their redundancy, absurdity, or explicit turn-down from Haxe developers.

Also, please note I have no experience in OCaml outside of modifying the Haxe compiler, so there are no guarentees I know what the hell I'm doing... just in case you actually look at the source code.

To learn more about Haxe, visit:\
[Official Haxe Github](https://github.com/HaxeFoundation/haxe)\
[Official Haxe Website](https://haxe.org/)\
[Official Haxe Download](https://haxe.org/download/)

---

# [Installation]

1) Download like you would with any version of Haxe from [Releases](https://github.com/RobertBorghese/haxe-saw/releases) or build it yourself.
2) Add it to your PC's "PATH" if necessary.
3) And/or if you're using Visual Studio Code add `"haxe.executable"` to your `settings.json` with the location of Haxe-SAW's `haxe.exe` as the value.

---
# [Features]

| Feature | Description |
| --- | --- |
| [`with` Feature](https://github.com/RobertBorghese/haxe-saw#with-feature) | Alias expression or fields for block |
| [Trailing Block Arguments](https://github.com/RobertBorghese/haxe-saw#trailing-block-arguments) | Pretty syntax for passing block expression as final argument |
| [Object Initializers](https://github.com/RobertBorghese/haxe-saw#object-initializers) | Initialize object fields on `new` expression |
| [Auto-Trace "All Alone" Strings](https://github.com/RobertBorghese/haxe-saw#auto-trace-all-alone-strings) | Auto-`trace` all alone strings |
| [`as` Operator](https://github.com/RobertBorghese/haxe-saw#as-operator) | Cast objects using standard `as` operator |
| [`unless` Expression](https://github.com/RobertBorghese/haxe-saw#unless-expression) | `if` statements for `false` expressions |
| [Modifier `if` and `unless`](https://github.com/RobertBorghese/haxe-saw#modifier-if-and-unless) | Suffix `if` statements for expressions |
| [Shorthand Nullable Types](https://github.com/RobertBorghese/haxe-saw#shorthand-nullable-types) | Add a `?` to the end of a type to wrap in `Null<..>` |
| [Shorthand Array Types](https://github.com/RobertBorghese/haxe-saw#shorthand-array-types) | Add a `[]` to the end of a type to wrap in `Array<..>` |
| [`if`/`while`/`for` No Parentheses](https://github.com/RobertBorghese/haxe-saw#ifwhilefor-no-parentheses) | Parentheses no longer required for common-use statements |
| [`const` Keyword](https://github.com/RobertBorghese/haxe-saw#const-keyword) | An alternative to the `final` keyword |
| [`struct` Keyword](https://github.com/RobertBorghese/haxe-saw#struct-keyword) | An alternative to the `class` keyword that adds the `@:struct` meta |
| [`fn` Keyword](https://github.com/RobertBorghese/haxe-saw#fn-keyword) | An alternative to the `function` keyword |

&nbsp;

# `with` Feature

Syntax sugar for aliasing an expression's resulting value or the value's fields to a new scope.

```haxe
var point = new Point(10, 20);

with p as point {
    trace(p.x, p.y); // 10, 20
}

with x, y from point {
    trace(x, y); // 10, 20
}
```

&nbsp;

# Trailing Block Arguments

[Kotlin's trailing lambdas](https://kotlinlang.org/docs/lambdas.html#passing-trailing-lambdas) provide users with the ability to use a nice syntax for passing a lambda as the final argument to a function. This feature works similarily, but instead of passing lambda functions, it passes a block scope (which executes and passes the final value at call-time). This works well with macro functions that can take the block scope as an `Expr` and modify it.

```haxe
// https://github.com/RobertBorghese/Haxe-ExtraFeatures/
using ExtraFeatures;

// ---

var player = new Player();

Math.floor(player.x / 100.0).with {
    trace(it);
}

var meters = player.getDistance().with(dist) {
    recordDistance(dist);
    triggerEffect() if dist > 1000;
    convertDistanceToMeters(dist); // convert to meters and return
}
```

&nbsp;

# Object Initializers

Based on [C#'s object initializers](https://docs.microsoft.com/en-us/dotnet/csharp/programming-guide/classes-and-structs/object-and-collection-initializers), this feature allows for a simple syntax to initialize multiple fields upon an object's creation.

```haxe
var c = new Color() {
    name = "blue";
    alpha = 0.5;
}

trace(c.name == "blue", c.alpha == 0.5); // true, true
```

&nbsp;

# Auto-Trace "All Alone" Strings

Based on [HolyC's Auto-Print](https://templeos.holyc.xyz/Wb/Doc/HolyC.html), this feature transforms any standalone Strings (that do not have any impact on the execution/value of its parent expression) into `trace` statements.

```haxe
"Hello World"; // equivalent to: trace("Hello World");

// prints "one" and "two", but not "three" since it gets stored in "result"
var result = {
    "one";
    "two";
    "three";
};

// print other values using either:
var num = 123;

'$num'; // string interpolation

"" + num; // or concatenation to empty-string
```

&nbsp;

# `as` Operator

Based on [C#'s `as` operator](https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/operators/type-testing-and-cast#as-operator). Converts an expression like this: `var as Type` to `cast(var, Type)`.

```haxe
var float: Float = 35.0;
var int = float as Int;
```

&nbsp;

# `unless` Expression

Based on [Ruby's `unless`](https://docs.ruby-lang.org/en/3.1/doc/syntax/control_expressions_rdoc.html#label-unless+Expression), this keyword can be used just like `if`, but the provided expression must be false to execute the block.

```haxe
const number = 123;

unless number == 0 {
    trace("This will print.");
} else if number == 123 {
    trace("This will not print.");
}
```

&nbsp;

# Modifier `if` and `unless`

Based on [Ruby's modifier conditions](https://docs.ruby-lang.org/en/3.1/doc/syntax/control_expressions_rdoc.html#label-Modifier+if+and+unless), conditions can be appended to any expression that doesn't end with a `}`. This is the equivalent of wrapping the expression with an `if` or `unless` condition.

```haxe
for(i in 0...inputNumber) {
    break if i > 10;
    continue if i % 2 == 1;
    evenNumbers.push(i);
}

player.update() if player.canUpdate();
player.draw() unless player.invisible();
```

&nbsp;

# Shorthand Nullable Types

Based on [Kotlin's nullable type syntax](https://kotlinlang.org/docs/null-safety.html#nullable-types-and-non-null-types), adding a `?` to the end of a type is the equavalent of surronding with `Null<...>`.

```haxe
@:nullSafety(Strict) {
    var test: Int? = Math.random() < 0.5 ? 100 : null;
}
```

&nbsp;

# Shorthand Array Types

Based on [Java's array type syntax](https://docs.oracle.com/javase/specs/jls/se7/html/jls-10.html), adding `[]` to the end of a type is the equavalent of surronding with `Array<...>`.

```haxe
@:nullSafety(Strict) {
    // Array<Int>
    var optA: Int[] = [1, 2, 3, 5, 8, 13];

    // Array<Null<Int>>
    var optB: Int?[] = [123, null, null, 321, null];

    // Null<Array<Int>>
    var optC: Int[]? = null;
}
```

&nbsp;

# `if`/`while`/`for` No Parentheses

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

# `const` Keyword

Based on [JavaScript's constant variable keyword](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/const). It works exactly like Haxe's `final` keyword.

```js
const str = "Hello";
str = "Goodbye"; // error: Cannot assign to final
```

&nbsp;

# `struct` Keyword

Based on [C#'s struct keyword](https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/builtin-types/struct). Automatically adds `@:struct` metadata to a class declaration if used instead of the `class` keyword.

```cs
// equivalent to:
// @:struct class MyStruct
struct MyStruct {
    public var data = 123;
    public function new(d: Int) { data = d; }
}
```

&nbsp;

# `fn` Keyword

Based on [Rust's function keyword](https://doc.rust-lang.org/book/ch03-03-how-functions-work.html). Can be used as a replacement for `function` in almost all cases.

```haxe
fn test() {
	trace("do thing");
}

fn main() {
	// "fn" can still be used as variable name for compatibility...
	var fn = () -> {
		trace("i am smol");
	};

	// ...as a result, it can't be used to create functions in expressions.
	// Use lambdas instead.
	var fn2 = fn() { // invalid
		trace("so am i");
	};
}
```
