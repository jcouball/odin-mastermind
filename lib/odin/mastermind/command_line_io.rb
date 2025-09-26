# frozen_string_literal: true

require_relative 'turn'
module Odin
  module Mastermind
    # Manages getting input from and sending output to the command line
    class CommandLineIO # rubocop:disable Metrics/ClassLength
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
        show_welcome_message
        show_instructions
        show_example_input
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
        if board.turns.empty?
          show_empty_board
        else
          show_board_with_turns(board:)
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

      # @param guess [Code] the duplicate guess
      #
      def show_duplicate_guess_error(guess:)
        colors = guess.values.map { |v| COLORS[v] }.join(' ')
        stdout.puts
        stdout.puts "Error: You've already guessed '#{colors}'. Please try again."
      end

      # Displays the game over message and announces the winner
      #
      # @param board [Board] the game board state
      #
      # @return [void]
      #
      def announce_winner(board:)
        stdout.puts
        stdout.puts "The #{winner(board)} wins after #{board.turns.length} guesses"
        return unless board.winner == :code_maker

        stdout.puts "The secret code was: #{board.secret_code.values.map { |v| COLORS[v] }.join(' ')}"
      end

      private

      def show_board_header
        stdout.puts
        stdout.puts ' ═════ M A S T E R M I N D   B O A R D ══════'
        stdout.puts '┌──────┬─────────────────────────────┬───────┐'
        stdout.puts '│ Turn │ Guess                       │ Match │'
      end

      def show_board_footer
        stdout.puts 'Available Colors'.center(46, ' ').rstrip
        stdout.puts conjoin(COLORS).center(46, ' ').rstrip
      end

      def show_empty_board
        show_board_header
        stdout.puts '├──────┴─────────────────────────────┴───────┤'
        stdout.puts '│     No guesses have been submitted yet     │'
        stdout.puts '└────────────────────────────────────────────┘'
        show_board_footer
      end

      def show_board_with_turns(board:)
        show_board_header
        stdout.puts '├──────┼─────────────────────────────┼───────┤'
        board.turns.each_with_index do |turn, index|
          num = (index + 1).to_s.rjust(4, ' ')
          guess = guess(turn)
          feedback = feedback(turn).ljust(5, ' ')
          stdout.puts "│ #{num} │ #{guess} │ #{feedback} │"
        end
        stdout.puts '└──────┴─────────────────────────────┴───────┘'
        show_board_footer
      end

      def show_welcome_message
        stdout.puts
        stdout.puts 'Welcome to Mastermind'
      end

      def show_instructions
        stdout.puts
        stdout.puts "Guess the secret code which contains #{config.code_length} values"
        stdout.puts
        stdout.puts 'Each value in the secret code is one of these colors:'
        stdout.puts conjoin(COLORS, 'or')
      end

      def show_example_input
        stdout.puts
        stdout.puts 'Example guess input:'
        stdout.puts 'red blue green yellow'
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

      # @param prompt [String] the prompt for the user
      # @return [Code] the code input from the user
      def prompt_for_code(prompt)
        colors = Enumerator.produce { ask_for_colors(prompt) }.find { |input| valid_colors?(input) }
        values = colors.map { |color| COLORS.index(color) }
        Code.new(values:, code_length: config.code_length, value_range: config.value_range)
      end

      # @param prompt [String] the prompt for the user
      # @return [Array<String>] the colors the user input
      def ask_for_colors(prompt)
        stdout.puts
        stdout.puts prompt
        stdin.gets.chomp.downcase.split
      end

      def valid_colors?(colors)
        valid_color_names?(colors) && valid_code_length?(colors)
      end

      def valid_color_names?(colors)
        invalid_colors = colors.reject { |color| COLORS.include?(color) }.uniq
        return true if invalid_colors.empty?

        invalid_colors_string = conjoin(invalid_colors)
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
      def conjoin(array, conjunction = 'and')
        return array[0] if array.length == 1
        return "#{array[0]} and #{array[1]}" if array.length == 2

        before_conjunction = array[0..(array.length - 2)]
        after_conjunction = array[-1]
        "#{before_conjunction.join(', ')}, #{conjunction} #{after_conjunction}"
      end
    end
  end
end
