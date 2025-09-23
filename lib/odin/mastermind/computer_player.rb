# frozen_string_literal: true

require_relative 'code'
require_relative 'player'

module Odin
  module Mastermind
    # A mastermind player with a name
    #
    class ComputerPlayer < Player
      def create_secret_code
        Code.new(values: random_values, code_length:, value_range:)
      end

      def make_guess(board:) # rubocop:disable Lint/UnusedMethodArgument
        # TODO: Will implement a better guessing algorithm later
        Code.new(values: random_values, code_length:, value_range:)
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
