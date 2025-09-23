# frozen_string_literal: true

require_relative 'player'

module Odin
  module Mastermind
    # A mastermind player with a name
    #
    class HumanPlayer < Player
      # @param name [String] the player's name
      # @param io [GameIO] the object used to interface with the player
      def initialize(name:, config:, game_io:)
        super(name:, config:)
        @game_io = game_io
      end

      # @return [GameIO] the object used to interface with the player
      attr_reader :game_io

      def create_secret_code
        game_io.create_secret_code
      end

      def make_guess(board:) # rubocop:disable Lint/UnusedMethodArgument
        game_io.make_guess
      end
    end
  end
end
