# VersionTools

![Current CI status](https://api.travis-ci.org/anicholson/crystal-version-tools.svg?branch=master)

Switch behaviour at Crystal compile-time based on versions, using macros.

You might want this if you need to support multiple versions of a dependency (with breaking changes),
while maintaining a consistent API for your consumers/callers.

## Installation

This shard is pre-release for now, so to use it in your project, you'll need to specify the `master` branch, like so:

```yaml
dependencies:
  version_tools:
    github: anicholson/crystal-version-tools
    branch: "master"
```

## Usage

Make sure to include the library in your project.

```crystal
require "version_tools"
```

### Built-in check: Crystal version being used

VersionTools provides a predefined checker that checks the version of Crystal being used
against a version you specify, like this:

```crystal
with_crystal_version("0.32.0") do
  greater do
    puts "#{Crystal::VERSION} is later than 0.32.0"
  end

  lesser_or_equal do
    puts "#{Crystal::VERSION} is earlier or equal to 0.32.0"
  end
end
```

This code snippet will compile to the following on each version:

```crystal
# on 0.32.1 or later
puts "#{Crystal::VERSION} is greater than 0.32.0"

# on 0.32.0 or earlier
puts "#{Crystal::VERSION} is earlier or equal to 0.32.0"
```

### Defining your own checker

If you wish to define your own checkers, use `define_version_checker!`.

For example, to create a checker called `with_api_version` that checks against (say) version "1.0.0" of something,
you invoke:

```crystal
VersionTools.define_version_checker!(with_api_version, "1.0.0")
```

And now you can use `with_api_version` the same way as `with_crystal_version` above.

### Scoped within modules

Defining a checker within a module scopes the checker to that module. For example:

```crystal
module Foo
  VersionTools.define_version_checker!(with_bar, "0.0.1")
end

# Works
Foo.with_bar("...") do
  #...
end

# Does not work
with_bar("...") do
  #...
end
```

### Supported clauses

The following clauses are supported.
In these tables, `my_version` refers to the version baked into the checker, and
`compared_version` refers to the version when the checker is _invoked_.

| Clause             | Description                         | Aliases                 |
|--------------------|-------------------------------------|-------------------------|
| `lesser`           | If `my_version < compared_version`  | `less_than`             |
| `lesser_or_equal`  | If `my_version <= compared_version` | `less_than_or_equal`    |
| `equal`            | If `my_version == compared_version` | `equals`                |
| `greater_or_equal` | If `my_version >= compared_version` | `greater_than_or_equal` |
| `greater`          | If `my_version > compared_version`  | `greater_than`          |

Any other clauses will raise a compile-time error:

```crystal
with_some_checker("1.0.0") do
  elephant do
    raise "Will not raise"
  end
end

# emits:
# 4 | VersionTools.define_version_checker!(with_some_checker, "0.1.0")
#     ^
# Error: Unknown clause: :elephant
```

Any code not within a clause will also raise a compile-time error:

```crystal
with_some_checker("1.0.0") do
  x = Object.new
end

# emits:
# 
#  4 | VersionTools.define_version_checker!(with_some_checker, "0.1.0")
#      ^
# Error: The following code caused an error:
# 
#   x = Object.new
# 
# Use a clause instead, for example:
#   greater do
#     # your code here
#   end
# 
# The following clauses are supported:
#   * lesser (or less_than)
#   * lesser_or_equal (or less_than_or_equal)
#   * equal (or equals)
#   * greater_or equal (or greater_than_or_equal)
#   * greater (or greater_than)
```

# Contributing

1.  Fork it ( anicholson/crystal-version-tools/fork )
2.  Create your feature branch (git checkout -b my-new-feature)
3.  Commit your changes (git commit -am 'Add some feature')
4.  Push to the branch (git push origin my-new-feature)
5.  Create a new Pull Request

# Contributors

- [anicholson](https://github.com/anicholson) Andy Nicholson - creator, maintainer
