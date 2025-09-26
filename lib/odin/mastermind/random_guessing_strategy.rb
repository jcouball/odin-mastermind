# frozen_string_literal: true

module Odin
  module Mastermind
    # A (not very good) strategy for making Mastermind guesses
    class RandomGuessingStrategy
      # @param code_length [Integer] the number of integers in a code
      # @param value_range [Range] the range each code digit must be within
      def initialize(code_length:, value_range:)
        @code_length = code_length
        @value_range = value_range
      end

      # @return [Integer] the number of integers in a code
      attr_reader :code_length

      # @return [Range] the range each code digit must be within
      attr_reader :value_range

      def next_guess(*)
        possible_values = value_range.to_a
        random_values = Array.new(code_length) { possible_values.sample }
        Code.new(values: random_values, code_length:, value_range:)
      end
    end
  end
end
