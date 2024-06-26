# Swift Coding Conventions

1. [API Design guidelines](#design-guidelines)
1. [Tabs](#tabs-and-indentation)
1. [Comments and autogenerated code](#comments)
1. [Semicolons](#semicolons)
1. [Curly Braces](#curly-braces)
1. [Naming](#naming)
1. [Immutability](#immutability)
1. [Access Control](#access-control)
1. [Closures](#closures)
1. [Objective-C runtime](#objective-c-runtime)
1. [Explicit references to self](#explicit-references-to-self)
1. [Optionals](#optionals)
1. [Implicit getters](#implicit-getters)
1. [Omitting type parameters](#omitting-type-parameters)
1. [Syntactic sugar](#syntactic-sugar)
1. [Struct initializers](#struct-initializers)
1. [Structuring code](#structuring-code)
1. [Extensions](#extensions)
1. [Namespacing](#namespacing)
1. [References](#references)

## Swift API Design Guidelines

Strictly follow [Swift 3 API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)

## Tabs and indentation

* Use spaces instead of tabs. Use Xcode setting, that replaces tab with 4 spaces(default).
* Always try to limit Line length to 100 characters.
* End files with a newline

## Comments

Remove autogenerated code and unused methods and variables. Don't write comments - code should be self-explanatory. Comments are only acceptable when they describe not obvious workaround in code, that can not be avoided or made more clear.

## Semicolons

Do not use semicolons at end of the line.

## Curly braces

Curly braces can be put on the same line as enclosing declaration, for example:

```swift
if foo != nil {
} else {

}
```

They can also be moved to the next line, if it makes code easier to read - mostly for long lines, for example

```swift
func extremelyAwesomeMethodWithMupltipleParameters(parameterOne: String,
    andClosure closure: String -> Void)
{

}
```

## Naming

Class, protocol and category names must consist of words and generally accepted abbreviations (Facebook - FB, etc.), each of which begins with a capital letter. Examples:

```swift
class ContactTableViewCell : UITableViewCell
class RefreshableDataSource
protocol AuthorizationDelegate
```

### Protocols

When picking a protocol name, always consider what your protocol is about. If it declares that type can be something else, use `Convertible` word in a name, for example

```swift
protocol JSONConvertible
protocol APIFilterConvertible
```

If your protocol defines an action or capability, that can be performed on or by instance of your object, use -able or -ible suffix:

```swift
protocol Streamable
protocol Mappable
protocol MemberContentVisible
```

If your protocol serves as a data source or a delegate, you can end name of your protocol with `DataSource` or `Delegate` ending.

### Variables

Variable names should begin with lower case letter. Use descriptive names to clarify your intent:

```swift
// Good:
let maximumPreviewCount = 5

//Bad
let MAX_PR_COUNT = 5
```

### Methods
For functions and methods, prefer named parameters unless intent and context are completely clear. Follow Apple convention to always name first argument in the name of the method:

```swift
class Counter {
    func combine(with: Counter) { ... }
    func increment(byAmount: Int) { ... }
}
```

### Typealiases

Typealiases should be short and meaningful. For example:

```swift
typealias MoneyAmount = Double

typealias ModelType
```

### Generic types

Generic types should start with letter `T`, then `U`, `V` and so on. You can use different names to make usage of generics more clear, for example:

```swift
public struct CollectionViewSection<Item>: CollectionViewSectionInfo {}
```

## Immutability

Always prefer `let` declarations over `var`. It clearly sends a message, that value will not be changed. If you don't need a variable, use nameless binding like so:

```swift
_ = methodThatReturnsUnusedVariable()
```

Prefer value types over reference types. Use structs instead of classes when you don't need reference semantics. Using value types provides a lot of benefits, such as protection against changing from different owners. It also frees you from memory management, because value types are copied instead of passing by reference. And it also provides thread-safety for your objects.

If your classes don't need any inheritance, mark them final to let compiler know, that class will not be subclassed.

```
final class User
{

}
```

This provides perfomance improvements in code compilation and in runtime - [Apple Swift Blog](https://developer.apple.com/swift/blog/?id=27).

## Access Control

Declare properties and methods `private`, when they should not be visible from outside of current file. Keep in mind, that private properties and methods are actually marked as `final` by compiler, optimizing perfomance. Don't add modifiers, if they are already a default. For example:

```swift
// Not preferred

internal extension String {
    var uppercaseString: String
}

// Preferred

extension String {
    var uppercaseString: String
}
```

## Closures

Use trailing closures, when intent is clear, and last parameter name is not relevant, for example:

```swift
// Not preferred
UIView.animate(withDuration:0.5, animations: {
            view.alpha = 1
})

// Preferred
UIView.animate(withDuration:0.5) {
    view.alpha = 1
}

```

Minimize parameter names that go inside closures to simplify closure syntax, for example:

```swift
// Not preferred
request.perform(success: { (responseObject, response) -> Void in
    // Do something
})

// Preferred
request.perform(success: { responseObject, _ in
    // Do something
})
```

Do not bluntly use `weak self` in every closure - figure out, where it is really needed  - most of the time it happens when closure is stored on your object. In previous examples with UIView animation it is not needed. And even if you do have retain cycles, if your object existance is guaranteed, use `[unowned self]` instead of weak to minimize optionals. Remember, that self is not the only one object, that can be part of retain cycles. If you have multiple arguments in capture list, remember to put weak or unowned before each one, for example:

```swift
let foo = Foo()
foo.performStuff { [weak self, unowned foo] in
    self?.method()
    foo.method()
}
```

You can omit parameter names in closures, if it's absolutely clear, what closure parameter is, for example:

```swift
let artworkDictionaryArray : [[String: AnyObject]] = ...

// Not preferred:
let parsedArtworksArray = artworkDictionaryArray.map({ dictionary in
    return Artwork(dictionary: dictionary)
})

// Preferred:
let parsedArtworksArray = artworkDictionaryArray.map { Artwork(dictionary: $0) }
```

As shown above, if your line is short, you can have curly braces on the same line.

## Objective-C runtime

Don't include objective-c runtime unless absolutely necessary. For example, Swift protocols do not allow optional methods. Instead of declaring protocol @objc, try to split protocols into several ones. Treat your protocols like traits, that may or may not be present. For example:

```swift
// Not Preferred
@objc protocol MovementAbilities {
    optional var speed: CGFloat { get }
    optional var maximumDepth : CGFloat { get }
}

class User: MovementAbilities {
    //...
}

// Preferred
protocol Runner {
    var speed: CGFloat { get }
}

protocol Swimmer {
    var maximumDepth : CGFloat { get }
}

class User: Runner, Swimmer {
    //...
}
```

Try to work with compile-time representations of data types instead of runtime. Avoid using `dynamic` attributes(unless it's CoreData, where it's required).

Use Swift native types instead of Objective-C ones whenever possible. For example, use `String` instead of `NSString`, and `Int` instead of `NSNumber`.

## Explicit references to `self`

Only use explicit `self` when compiler requires you to, for example in constructors

```swift
struct Person {
    let firstName: String
    let lastName : String

    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }
}
```

or in closures.

## Optionals

Avoid using force unwrapping. Use optional chaining or `if let` bindings to unwrap optional values.

```swift
var name: String?
var age: String?

if let name = name, age = age, age >= 13 {
    // ...
}

foo?.callSomethingIfFooIsNotNil()
```

Use nil-coalescing operator to avoid using force-unwrapping or checking for nil, for example:

```swift
if user?.isValid ?? false {
    // .. Do something
}
```

Use guard construct to break/return early.

```swift
func makePaymentForUser(user: User) {
    guard let creditCard = user.creditCard else {
        return
    }

    creditCard.withdrawAmount(500000)
}
```

There are several cases, where usage of force unwrapping is allowed. For example, IBOutlets are guaranteed to exist, and you need to crash application if they don't, so this is allowed:

```swift
class ProfileViewController : UIViewController {
    @IBOutlet weak var firstNameTextField : UITextField!
}
```

Another use case is unit tests, if you have your "system under test" created in setup method:

```swift
class UserTestCase : XCTestCase {
    var sut : User!

    func setUp() {
        super.setUp()
        sut = User.fixture()
    }

    func testUser() {
        XCTAssert(sut.isValid())
    }
}
```

## Implicit getters

Read-only computed properties don't need explicit getter:

```swift
// Not Preferred
var quality : CGFloat {
    get {
        return 5.0
    }
}

// Preferred
var quality : CGFloat {
    return 5.0
}

```

## Omitting type parameters

Omit type parameters, when they can be inferred by compiler, for example:

```swift
// Not preferred:
var color : UIColor = UIColor.clear
view.backgroundColor = UIColor.clear

// Preferred:
var color = UIColor.clear
view.backgroundColor = .clear
```

## Syntactic sugar

Prefer shortcut versions of type declarations over full generics syntax:

```swift
// Not preferred:
let models : Array<String>

//Preferred:
let models: [String]
```

## Struct initializers

Use native Swift initializers rather then legacy CGGeometry constructors

```swift
// Not preferred:

let bounds = CGRectMake(40, 20, 120, 80)
let centerPoint = CGPointMake(96, 42)

// Preferred:

let bounds = CGRect(x: 40, y: 20, width: 120, height: 80)
let centerPoint = CGPoint(x: 96, y: 42)
```

Prefer struct-scope constants like `Int.max` to legacy ones like `CGRectZero`.

## Structuring code

When conforming to a protocol, create extension with conformance methods:

```swift
class MyViewController: UIViewController {

}

extension MyViewController : UIScrollViewDelegate {
    // Scroll View delegate methods
}
```

Add pragma marks to make particular code block clear:

```swift
class MyViewController : UIViewController {

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // ...
    }

    // MARK: - Actions

    @IBAction func buttonTapped() {

    }
}
```

In general, try to keep files simple. Every file, that has more than 200 lines of code, needs to have a valid reason to be like that. If your source file size is more than 500 lines, this should be considered a technical debt, and be split into several files.

## Extensions

When picking extension file name, consider functionality you are providing. For example, if you write extension on UIImage, that will provide placeholders, name it `UIImage+Placeholders`. If it is hard to determine, which functionality is added, using one word, name it with `+Extensions` suffix like so: `UIImage+Extensions`.

## Namespacing

You can use namespacing to make code usage more clear. Until proper namespaces are added to Swift, use enums for pure namespacing purposes:

```swift
enum API {
    enum Users {
        static func get() -> [User]
    }
}

let users = API.Users.get()
```

## References

* [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
* [Swift programming language book](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/)
* [Github Swift guidelines](https://github.com/github/swift-style-guide)
* [raywenderlich.com Swift guidelines](https://github.com/raywenderlich/swift-style-guide)
* [MLSDev Swift guidelines](https://github.com/MLSDev/development-standards/blob/master/platform/ios/swift-coding-conventions.md)
