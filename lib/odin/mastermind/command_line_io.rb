# frozen_string_literal: true

require_relative 'turn'
module Odin
  module Mastermind
    # Manages getting input from and sending output to the command line
    class CommandLineIO
      COLORS = %w[red blue green yellow orange black].freeze

      # @param config [Configuration] the game configuration
      def initialize(config:, stdout:, stdin:)
        @config = config
        @stdout = stdout
        @stdin = stdin
      end

      # @return [Configuration] the game configuration
      attr_reader :config

      # @return [IO] where to send Mastermind output
      attr_reader :stdout

      # @return [IO] where to get Mastermind input
      attr_reader :stdin

      # Announce the start of the game
      #
      # @return [void]
      #
      def start_game
        stdout.puts "Welcome to Mastermind\n"
      end

      # Prompts the code maker to enter the secret code for the game
      #
      # @return [Code]
      #
      def create_secret_code
        prompt_for_code('Enter the secret code:')
      end

      # Displays the current state of the board including past turns
      #
      # @param board [Board] the game board state
      #
      # @return [void]
      #
      def show_board(board:)
        stdout.puts 'M A S T E R M I N D   B O A R D'
        stdout.puts 'Turn  Guess                        Match'
        stdout.puts '----  ---------------------------  -----'
        if board.turns.empty?
          stdout.puts 'No guesses have been submitted yet'
        else
          show_turns(board:)
        end
      end

      # Prompts the code breaker to enter their next guess
      #
      # @param board [Board] the game board state up to this turn
      #
      # @return [Code] the guess entered
      #
      def make_guess(board:)
        guesses_remaining = config.max_turns - board.turns.size
        prompt_for_code("There are #{guesses_remaining} remaining guesses. Enter a guess:")
      end

      # Displays the game over message and announces the winner
      #
      # @param board [Board] the game board state
      #
      # @return [void]
      #
      def announce_winner(board:)
        stdout.puts "The #{winner(board)} wins after #{board.turns.length} guesses"
      end

      private

      def show_turns(board:)
        board.turns.each_with_index do |turn, index|
          num = (index + 1).to_s.rjust(2, '0')
          stdout.puts "  #{num}  #{guess(turn)}  #{feedback(turn)}"
        end
      end

      def guess(turn)
        turn.guess.values.map do |v|
          COLORS[v].ljust(6, ' ')
        end.join(' ')
      end

      def feedback(turn)
        exact_matches = 'X' * turn.feedback.exact_matches
        partial_matches = 'O' * turn.feedback.partial_matches
        "#{exact_matches}#{partial_matches}"
      end

      def winner(board)
        board.winner == :code_breaker ? 'code breaker' : 'code maker'
      end

      def prompt_for_code(prompt)
        loop do
          stdout.puts prompt
          input = stdin.gets.chomp.downcase
          colors = input.split

          next unless valid_colors?(colors)

          values = colors.map { |color| COLORS.index(color) }
          return Code.new(values:, code_length: config.code_length, value_range: config.value_range)
        end
      end

      def valid_colors?(colors)
        valid_color_names?(colors) && valid_code_length?(colors)
      end

      def valid_color_names?(colors)
        invalid_colors = colors.reject { |color| COLORS.include?(color) }
        return true if invalid_colors.empty?

        invalid_colors_string = contraction(invalid_colors)
        if invalid_colors.one?
          stdout.puts "Error: #{invalid_colors_string} is not a valid color. Please try again."
        else
          stdout.puts "Error: #{invalid_colors_string} are not valid colors. Please try again."
        end
        false
      end

      def valid_code_length?(colors)
        return true if colors.length == config.code_length

        stdout.puts "Error: the code needs to have #{config.code_length} colors. Please try again."
        false
      end

      # Creates a comma separated string of the given array of strings using oxford comma rules
      # @param array [Array<String>] the array of string to join
      def contraction(array)
        return array[0] if array.length == 1
        return "#{array[0]} and #{array[1]}" if array.length == 2

        before_contraction = array[0..(array.length - 2)]
        after_contraction = array[-1]
        "#{before_contraction.join(', ')}, and #{after_contraction}"
      end
    end
  end
end
