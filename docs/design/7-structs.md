# Structs

Defining and using structs

---

## Struct Definition

Struct members (fields and methods) are all declared inside the struct body:
```
struct Name {

	// fields
	var v1: u32;
	var v2: str = "bar";  // default value

	// method
	mtd foo() -> u32 {
		return 5;
	}
}
```

---

## Instantiation

Instantiation uses braces and supports partial initialization:
```
struct FooBar {
    var foo: str;
    var bar: str;	
}

var foobar = FooBar {
	foo: "bar",
};
```

---

## Accessing Instance Members

Instance members are accessed with the `.` operator (auto-dereferences struct pointers).

Access from outside the instance uses symbol prefix:
```
var person = Person {
	name: "Dave",
};

println(person.name);
```

Access from within the instance uses no prefix:
```
struct Person {
	var name: str;

	mtd greet() {
		println("Hello, I am " + .name);
	}
}
```

---

⬅️ [Heap Allocation](./6-heap-alloc.md)
