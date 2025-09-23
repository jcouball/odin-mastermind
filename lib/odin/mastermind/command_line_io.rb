# frozen_string_literal: true

require_relative 'turn'

module Odin
  module Mastermind
    # Manages getting input from and sending output to the command line
    class CommandLineIO
      # @param config [Configuration] the game configuration
      def initialize(config:)
        @config = config
      end

      # @return [Configuration] the game configuration
      attr_reader :config

      # Announces the start of the game
      #
      # @return [void]
      #
      def start_game
        raise NotImplementedError
      end

      # Prompts the code maker to enter the secret code for the game
      #
      # @return [Code]
      #
      def create_secret_code
        raise NotImplementedError
      end

      # Displays the current state of the board including past turns
      #
      # @param board [Board] the game board state
      #
      # @return [void]
      #
      def show_board(board:)
        raise NotImplementedError
      end

      # Prompts the code breaker to enter their next guess
      #
      # @param board [Board] the game board state up to this turn
      #
      # @return [Code] the guess entered
      #
      def make_guess(board:)
        raise NotImplementedError
      end

      # Displays the game over message and announces the winner
      #
      # @param board [Board] the game board state
      #
      # @return [void]
      #
      def announce_winner(board:)
        raise NotImplementedError
      end
    end
  end
end
