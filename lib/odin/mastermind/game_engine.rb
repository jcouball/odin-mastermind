# frozen_string_literal: true

require_relative 'board'

module Odin
  module Mastermind
    # Runs a game of Mastermind
    #
    class GameEngine
      # @param code_maker [Player] the player that makes the secret code
      # @param code_breaker [Player] the player that tries to guess the secret code
      # @param config [Configuration] the game configuration
      # @param game_io [GameIO] sends output to and collectes input from the players
      def initialize(code_maker:, code_breaker:, config:, game_io:)
        @code_maker = code_maker
        @code_breaker = code_breaker
        @config = config
        @game_io = game_io
        @board = nil
      end

      # @return [Player] the player that makes the secret code
      attr_reader :code_maker

      # @return [Player] the player that tries to guess the secret code
      attr_reader :code_breaker

      # @return [Configuration] the game configuration
      attr_reader :config

      # @return [GameIO] sends output to and collectes input from the players
      attr_reader :game_io

      # @return [Board] the game state including secret code and past turns
      attr_reader :board

      def run
        start_game
        create_secret_code
        make_guesses
        end_game
      end

      private

      def start_game
        game_io.start_game
      end

      def create_secret_code
        secret_code = code_maker.create_secret_code
        @board = Board.new(secret_code:, max_turns: config.max_turns)
      end

      def make_guesses
        until board.game_over?
          game_io.show_board(board:)
          guess = code_breaker.make_guess(board:)
          board.add_guess(guess:)
        end
      end

      def end_game
        game_io.announce_winner(board:)
      end
    end
  end
end
