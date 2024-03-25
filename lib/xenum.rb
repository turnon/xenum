# frozen_string_literal: true

require_relative "xenum/version"
require_relative "xenum/merge_sort"

module Xenum
end

module Enumerable
  def lazy_flatten(level = nil)
    these = self
    level = -1 if level.nil?

    Enumerator.new do |yielder|
      level.nil?
      these.each do |this|
        if Enumerable === this && level != 0
          this.lazy_flatten(level - 1).each do |sub|
             yielder.yield(sub)
          end
          next
        end

        yielder.yield(this)
      end
    end
  end

  def lazy_insert(index, *objs)
    return self if objs.empty?

    if index >= 0
      lazy_insert_pos(index, objs)
    else
      lazy_insert_neg(index, objs)
    end
  end

  def lazy_unshift(*objs)
    lazy_insert(0, *objs)
  end

  def lazy_product(*enums)
    if enums.empty?
      return Enumerator.new do |yielder|
        each do |this|
          yielder.yield([this])
        end
      end
    end

    Enumerator.new do |yielder|
      each do |this|
        head = [this]
        enums[0].lazy_product(*enums[1..-1]).each do |tail|
          yielder.yield(head + tail)
        end
      end
    end
  end

  def merge_sort(*enums)
    enums << self
    Xenum::MergeSort.iter(*enums)
  end

  private


  def lazy_insert_neg(index, objs)
    these = Enumerator === self ? self : self.to_enum
    queue = []

    (index.abs - 1).times do
      begin
        queue << these.next
      rescue StopIteration
        raise IndexError, "index #{index} too small; minimum: #{-(queue.size + 1)}"
      end
    end

    Enumerator.new do |yielder|
      loop do
        begin
          queue << these.next
          yielder << queue.shift
        rescue StopIteration
          break
        end
      end
      objs.each{ |obj| yielder << obj }
      queue.each{ |this| yielder << this }
    end
  end

  def lazy_insert_pos(index, objs)
    these = self
    Enumerator.new do |yielder|
      current_index = -1
      these.each do |this|
        current_index += 1
        objs.each{ |obj| yielder << obj } if current_index == index
        yielder << this
      end
      if current_index < index
        ((current_index + 1)...index).each{ yielder << nil }
        objs.each{ |obj| yielder << obj }
      end
    end
  end
end
