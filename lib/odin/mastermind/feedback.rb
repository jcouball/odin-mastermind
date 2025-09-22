# frozen_string_literal: true

module Odin
  module Mastermind
    # Count the number of exact and partial matches between secret_code and guess
    #
    class Feedback
      # @param secret_code [Odin::Mastermind::Code]
      # @param guess [Odin::Mastermind::Code]
      def initialize(secret_code:, guess:)
        @secret_code = secret_code
        @guess = guess

        @exact_matches = 0
        @partial_matches = 0

        secret_code_values = secret_code.values.dup
        guess_values = guess.values.dup

        count_and_remove_exact_matches(secret_code_values, guess_values)
        count_and_remove_partial_matches(secret_code_values, guess_values)
      end

      # @return [Code] the code trying to be guessed
      attr_reader :secret_code

      # @return [Code] the guess
      attr_reader :guess

      # @return [Integer] the number of values in guess that are in secret_code in the same position
      attr_reader :exact_matches

      # @return [Integer] the number of values in guess that are in secret_code that are not exact matches
      attr_reader :partial_matches

      private

      # Counts the number of exact matches between secret_code_values and guess_values
      #
      # The matching values in secret_code_values and guess_values are set to nil so
      # they are used only once (this is what is meant by 'remove').
      #
      # @return [void]
      #
      def count_and_remove_exact_matches(secret_code_values, guess_values)
        secret_code_values.each_with_index do |value, index|
          next unless guess_values[index] == value

          @exact_matches += 1
          secret_code_values[index] = guess_values[index] = nil
        end
      end

      # Modifies the content of secret_code_values and guess_values
      #
      # The matching values in secret_code_values and guess_values are set to nil so
      # they are used only once (this is what is meant by 'remove').
      #
      # @return [void]
      #
      def count_and_remove_partial_matches(secret_code_values, guess_values)
        secret_code_values.each do |value|
          next if value.nil? # value already an exact match

          guess_index = guess_values.index(value)
          next if guess_index.nil?

          @partial_matches += 1
          guess_values[guess_index] = nil
        end
      end
    end
  end
end
