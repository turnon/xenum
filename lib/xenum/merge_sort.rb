module Xenum
  module MergeSort
    NULL = Object.new

    class << self
      def recur(*enums)
        case enums.size
        when 0
          [].to_enum
        when 1
          enums[0]
        else
          enums2 = recur(*enums.pop(enums.size / 2))
          enums1 = recur(*enums)
          _recur(enums1, enums2)
        end
      end

      def iter(*enums)
        Enumerator.new do |yielder|
          enums = enums.each_with_object([]) do |e, arr|
            c = Candidate.new(e)
            arr << c if c.value != NULL
          end
          enums.sort!{ |a, b| b <=> a }

          resort = -> do
            i = -1
            x = enums[i]
            loop do
              e = enums[i-1]
              break unless e
              break if (e <=> x) >= 0
              enums[i] = e
              i -= 1
            end
            enums[i] = x
          end

          loop do
            break if enums.empty?
            resort.call
            least = enums[-1]
            yielder << least.value
            least.fetch
            next enums.pop if least.value == NULL
          end
        end
      end

      private

      def _recur(this, that)
        this = this.to_enum unless Enumerator === this
        that = that.to_enum unless Enumerator === that

        Enumerator.new do |e|
          a = NULL
          b = NULL
          remain = nil

          loop do
            if a == NULL
              a = begin
                    this.next
                  rescue StopIteration
                    remain = that
                    break
                  end
            end

            if b == NULL
              b = begin
                    that.next
                  rescue StopIteration
                    remain = this
                    break
                  end
            end

            if (a <=> b) <= 0
              e.yield(a)
              a = NULL
            else
              e.yield(b)
              b = NULL
            end
          end

          e.yield(a) if a != NULL
          e.yield(b) if b != NULL

          loop do
            e.yield(remain.next)
          rescue StopIteration
            break
          end
        end
      end
    end

    class Candidate
      attr_accessor :value

      def initialize(enum)
        @enum = Enumerator === enum ? enum : enum.to_enum
        fetch
      end

      def <=>(another)
        value <=> another.value
      end

      def fetch
        @value = @enum.next
      rescue StopIteration
        @value = NULL
      end
    end
  end
end
