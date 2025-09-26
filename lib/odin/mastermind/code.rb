# frozen_string_literal: true

module Odin
  module Mastermind
    # An ordered set of values defined by code_length and value_range
    class Code
      def initialize(values:, code_length:, value_range:)
        validate_code_length(code_length)
        validate_value_range(value_range)
        validate_values(values, code_length)
        validate_each_value(values, value_range)

        @values = values.dup.freeze
        @code_length = code_length
        @value_range = value_range
      end

      attr_reader :values, :code_length, :value_range

      # Return a Set of all possible codes given the code_length and value_range
      #
      # @param code_length [Integer] the number of integers that make up the code
      #
      # @param value_range [Range] the range that each integer must fall within
      #
      # @return [Set]
      #
      def self.all_possible_codes(code_length:, value_range:)
        value_range.to_a.repeated_permutation(code_length).to_set do |values|
          new(values:, code_length:, value_range:)
        end
      end

      include Comparable

      def <=>(other)
        return nil unless other.is_a?(Code)

        values <=> other.values
      end

      def hash
        values.hash
      end

      private

      def validate_code_length(code_length)
        unless code_length.is_a?(Integer)
          raise TypeError, "Expected code_length to be an Integer but it was a #{code_length.class}"
        end
        raise ArgumentError, "Expected code_length to be positive but was #{code_length}" unless code_length.positive?
      end

      def validate_value_range(value_range)
        unless value_range.is_a?(Range)
          raise TypeError, "Expected value_range to be a Range but it was a #{value_range.class}"
        end
        raise ArgumentError, 'Expected value_range to be iterable' unless value_range.first.respond_to?(:succ)
      end

      def validate_values(values, code_length)
        raise TypeError, "Expected values to be an Array but it was a #{values.class}" unless values.is_a?(Array)

        return if values.length == code_length

        raise ArgumentError, "Expected values.length to be #{code_length} but was #{values.length}"
      end

      def validate_each_value(values, value_range)
        return if values.all? { |v| v.is_a?(value_range.begin.class) && value_range.include?(v) }

        raise ArgumentError, "All values must be of type #{value_range.begin.class} and within the range"
      end
    end
  end
end
