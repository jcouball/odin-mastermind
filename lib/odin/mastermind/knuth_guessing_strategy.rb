# frozen_string_literal: true

module Odin
  module Mastermind
    # A better strategy for making Mastermind guesses
    class KnuthGuessingStrategy
      # @param code_length [Integer] the number of integers in a code
      #
      # @param value_range [Range] the range each code digit must be within
      #
      def initialize(code_length:, value_range:)
        @code_length = code_length
        @value_range = value_range
        @all_possible_codes = Code.all_possible_codes(code_length:, value_range:).freeze
        @possible_secret_codes = all_possible_codes.dup
      end

      # @return [Integer] the number of integers in a code
      attr_reader :code_length

      # @return [Range] the range each code digit must be within
      attr_reader :value_range

      # @return [Set] a set of all possible codes for the given code_length and value_range
      attr_reader :all_possible_codes

      # @return [Set] a set of possible secret codes which is reduced each turn
      attr_reader :possible_secret_codes

      # @param board [Board] the past guesses and last feedback are used for this algorithm
      #
      def next_guess(board:)
        # Start with an initial guess if "0011"
        return first_guess if board.turns.empty?

        prune_possible_codes(last_turn: board.turns.last)
        unused_codes = all_possible_codes - board.turns.map(&:guess)
        choose_next_guess(unused_codes:)
      end

      private

      # Return the a set of Codes which represent the best candidates for the next
      # guesses
      #
      # @param minimax_scores [Hash<Code => Integer>] the minimax score for each
      # unused code
      #
      def select_best_guesses(unused_codes:)
        # Narrow down the list of possible next guesses based on the minimax score
        # for each unused code
        minimax_scores = minimax_scores(unused_codes:)
        # Find the highest minimax score
        highest_score = minimax_scores.values.max
        # Return the set of all the codes from `unused_codes` tied for highest
        # minimax score
        minimax_scores.select { |_, score| score == highest_score }.keys.to_set
      end

      # @param unused_codes [Set] the set of all possible codes not already used in the game
      #
      # @return [Code] the next guess selected
      #
      def choose_next_guess(unused_codes:)
        best_guesses = select_best_guesses(unused_codes:)

        # From the best guesses, prefer any that are also possible secret codes.
        preferred_guesses = best_guesses & possible_secret_codes

        # If the preferred set isn't empty, choose from it; otherwise, fall back to
        # the original set of best guesses.
        (preferred_guesses.empty? ? best_guesses : preferred_guesses).min
      end

      # @param unused_codes [Set] all possible codes that haven't been used in the game yet
      #
      # @return [Hash<Code => Integer>] the minimax score for each code from unused_codes
      #
      def minimax_scores(unused_codes:)
        unused_codes.to_h { |code| [code, minimax_score_for(guess: code)] }
      end

      # @param guess [Code] the code whose score to find
      #
      # @return [Integer] score
      #
      def minimax_score_for(guess:)
        tally = Hash.new(0)

        possible_secret_codes.each do |secret_code|
          feedback = Feedback.new(secret_code:, guess:)
          key = [feedback.exact_matches, feedback.partial_matches]
          tally[key] += 1
        end

        elimination_counts = tally.transform_values { |v| possible_secret_codes.size - v }

        elimination_counts.values.min || 0
      end

      # Remove codes from #possible_secret_codes that do not give the same
      # feedback as the last turn
      #
      # @param last_turn [Turn] the #guess and #feedback are used
      #
      # @return [void]
      #
      def prune_possible_codes(last_turn:)
        possible_secret_codes.select! do |code|
          Feedback.new(secret_code: code, guess: last_turn.guess) == last_turn.feedback
        end
      end

      def first_guess
        Code.new(values: first_guess_values, code_length:, value_range:)
      end

      # Knuth calls for the starting guess to always be [0, 0, 1, 1]
      #
      # This tries to replicate the intent of that for any code_length and value range.
      #
      # @return [Array<Integer>] the values to use for the first guess
      #
      def first_guess_values
        first_val = value_range.begin

        # If there's only one possible value, the guess must use it for all positions
        return [first_val] * code_length if value_range.count < 2

        second_val = first_val.succ

        # Split the code_length into two halves, favoring the first split if the length is odd
        first_half_size = (code_length / 2.0).ceil
        second_half_size = code_length - first_half_size

        ([first_val] * first_half_size) + ([second_val] * second_half_size)
      end
    end
  end
end
