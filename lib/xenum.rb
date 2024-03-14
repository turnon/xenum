# frozen_string_literal: true

require_relative "xenum/version"

module Xenum
end

module Enumerable
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
end
