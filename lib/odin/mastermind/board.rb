# frozen_string_literal: true

require_relative 'turn'

module Odin
  module Mastermind
    # An ordered set of values defined by code_length and value_range
    class Board
      def initialize(secret_code:, max_turns:)
        @secret_code = secret_code
        @max_turns = max_turns
        @turns = []
      end

      # @return [Code] the secret code the code breaker is trying to guess
      attr_reader :secret_code

      # @return [Integer] the number of turns allowed before declaring the code maker the winner
      attr_reader :max_turns

      # @return [Array<Turn>] the history of turns in the game
      attr_reader :turns

      # @param guess [Code] the code breaker's guess for the next turn
      def add_guess(guess:)
        raise GameOverError, 'The game is over' if game_over?

        feedback = Feedback.new(secret_code:, guess:)
        @turns << Turn.new(guess:, feedback:)
      end

      # @return [Symbol] returns :code_breaker, :code_maker, or nil
      #
      #   * returns :code_breaker if the secret code was guessed
      #   * returns :code_maker if the secret code was not guessed within max_turns guesses
      #   * otherwise returns nil
      #
      def winner
        return nil if turns.empty?
        return :code_breaker if turns.last.feedback.exact_matches == secret_code.code_length
        return :code_maker if turns.length == max_turns

        nil
      end

      # @return [Boolean] true if there is a correct guess or max_turns number of turns
      def game_over?
        !winner.nil?
      end
    end
  end
end
