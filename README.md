# Festoon

## What is it?

This project aspires to better enable object composition by offering a set of
super classes and modules akin to the standard library's `SimpleDelegator`.

## Why is it?

Personally I've felt the delegation tools in the standard library to be lacking
in functionality, often difficult to use in practice and sometimes misleading.

The following is a issues I have encountered (not comprehensive)

* Delegation of `#inspect` causing the SimpleDelegator to masquerade as the
object it decorates.
* Comparison of decorated objects only works for coercible primitives.
* Fluid interfaces, where the decorated object returns self, are not supported
and cause your composed objects to unravel.
* Difficulty in debugging with multple layers of decoration

## Examples

### Equality

```ruby
my_object = Object.new

Festoon::Dynamic.new(my_object) == Festoon::Dynamic.new(my_object)
=> true
```

### Fluid interfaces, return of self

```ruby
class MyClass
  def returns_self
    self
  end
end

my_object = MyClass.new

Festoon::Dynamic.new(my_object).returns_self.class
=> Festoon::Dynamic
```

### Inspection

```ruby
Festoon::Dynamic.new(my_object).inspect
=> #<Festoon::Dynamic:0x0000010108af28 @thing=#<Object:0x0000010108af50>>
```

### Compose and `__decompose__`

`#__decompose__` returns an array, each element containing a layer of the
composed object outermost first. This is most easily demonstrable by mapping
each layer to its class.

This mainly exists for debugging and allow you to inspect, interact and bypass
arbitrary layers of the composition.

```ruby
class DecoratorA < Festoon::Dynamic; end

class DecoratorB < Festoon::Dynamic; end

composed_object = DecoratorB.new(DecoratorA.new(MyClass.new))

composed_object.__decompose__.map { |o| o.class }
=> [DecoratorB, DecoratorA, MyClass]

composed_object.__decompose__
=> [
    #<DecoratorB:0x00000102003770 @thing=#<DecoratorA:0x00000102003798 @thing=#<MyClass:0x00000102003e28>>>,
    #<DecoratorA:0x00000102003798 @thing=#<MyClass:0x00000102003e28>>,
    #<MyClass:0x00000102003e28>
  ]
```

## TODO

* Method reflection methods such as `#public_methods` etc
* Consider delegation of `#trust`, `#untrust`, `#taint`, `#untaint`, `#freeze`
* `#inspect` method which has readable output and does not attempt to hide the
object's composed nature. Potentially offer a set of strategies for this.
* Recursive `#dup`?
* Hash equality
* Rename `@thing`

## Installation

Add this line to your application's Gemfile:

```ruby
gem "festoon"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install festoon

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/[my-github-username]/festoon/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
