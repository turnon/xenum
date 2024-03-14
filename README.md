# Xenum

Extend Enumerable

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add xenum

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install xenum

## Usage

`lazy_product` works like `Array#product`, but not limited to `Array`

```ruby
3.times.lazy_product((3..5), [6,7,8]).take(6)
# [[0, 3, 6], [0, 3, 7], [0, 3, 8], [0, 4, 6], [0, 4, 7], [0, 4, 8]]
```

