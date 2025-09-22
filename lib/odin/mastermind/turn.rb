# frozen_string_literal: true

module Odin
  module Mastermind
    # Associates a guess with its feedback
    class Turn
      # @param guess [Code] the guess for this turn
      # @param feedback [Feedback] the number of matches between the guess and the secret code
      def initialize(guess:, feedback:)
        @guess = guess
        @feedback = feedback
      end

      # @return [Code] the code breaker's guess for this turn
      attr_reader :guess

      # @return [Feedback] the number of matches between the guess and the secret code
      attr_reader :feedback
    end
  end
end
