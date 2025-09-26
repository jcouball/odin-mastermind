# frozen_string_literal: true

require_relative 'code'
require_relative 'player'
require_relative 'random_guessing_strategy'

module Odin
  module Mastermind
    # A mastermind player with a name
    #
    class ComputerPlayer < Player
      def create_secret_code
        Code.new(values: random_values, code_length:, value_range:)
      end

      def make_guess(board:)
        guessing_strategy.next_guess(board:)
      end

      def guessing_strategy
        @guessing_strategy ||= RandomGuessingStrategy.new(code_length:, value_range:)
      end

      private

      def random_values
        possible_values = value_range.to_a
        Array.new(code_length) { possible_values.sample }
      end

      def code_length = config.code_length

      def value_range = config.value_range
    end
  end
end
