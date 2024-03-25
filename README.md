# Xenum

Extend Enumerable

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add xenum

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install xenum

## Usage

### lazy_flatten

works like `Array#flatten`, but for all `Enumerable`, and it is lazy

```ruby
[
  3.times,
  3,
  4,
  [5, [6,7]],
  (8..10),
  Enumerator.new{|e| n = 10; loop{e << n+=1}}
].lazy_flatten.first(15)
# [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
```

### lazy_insert

works like `Array#insert`, but not limited to `Array`

```ruby
10.times.lazy_insert(3, 'a', 'b').to_a
# [0, 1, 2, "a", "b", 3, 4, 5, 6, 7, 8, 9]

10.times.lazy_insert(-3, 'a', 'b').to_a
# [0, 1, 2, 3, 4, 5, 6, 7, "a", "b", 8, 9]
```

### lazy_unshift

just like `lazy_insert(0, ...)`

### lazy_product

works like `Array#product`, but not limited to `Array`

```ruby
3.times.lazy_product(
  (3..5),
  [6,7,8]
).take(6)
# [[0, 3, 6], [0, 3, 7], [0, 3, 8], [0, 4, 6], [0, 4, 7], [0, 4, 8]]
```

### merge_sort

lazily merge sort `Enumerable`

```ruby
e = (6..8).merge_sort([3,4,5]).merge_sort(3.times)
# #<Enumerator: ...>

e.take(5)
# [0, 1, 2, 3, 4]

[(6..8), [3,4,5], 3.times].reduce(&:merge_sort).to_a
# [0, 1, 2, 3, 4, 5, 6, 7, 8]

# same result but faster
(6..8).merge_sort([3,4,5], 3.times).to_a
# [0, 1, 2, 3, 4, 5, 6, 7, 8]
```
