# frozen_string_literal: true

require_relative "xenum/version"

module Xenum
  NULL = Object.new
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

  def merge_sort(that)
    this = Enumerator === self ? self : self.to_enum
    that = Enumerator === that ? that : that.to_enum

    Enumerator.new do |e|
      a = Xenum::NULL
      b = Xenum::NULL
      remain = nil

      loop do
        if a == Xenum::NULL
          a = begin
                this.next
              rescue StopIteration
                remain = that
                break
              end
        end

        if b == Xenum::NULL
          b = begin
                that.next
              rescue StopIteration
                remain = this
                break
              end
        end

        if (a <=> b) <= 0
          e.yield(a)
          a = Xenum::NULL
        else
          e.yield(b)
          b = Xenum::NULL
        end
      end

      e.yield(a) if a != Xenum::NULL
      e.yield(b) if b != Xenum::NULL

      loop do
        e.yield(remain.next)
      rescue StopIteration
        break
      end
    end
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
