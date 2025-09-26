# frozen_string_literal: true

RSpec.describe Odin::Mastermind::CommandLineIO do
  let(:colors) { described_class::COLORS }

  let(:described_object) { described_class.new(config:, stdout:, stdin:) }
  let(:config) { Odin::Mastermind::Configuration.new(code_length:, value_range:, max_turns:) }

  let(:secret_code_values) { [0, 1, 2, 3] }
  let(:secret_code) { Odin::Mastermind::Code.new(values: secret_code_values, code_length:, value_range:) }
  let(:secret_code_colors) { secret_code_values.map { |value| colors[value] } }

  let(:board) { Odin::Mastermind::Board.new(secret_code:, max_turns:) }

  let(:code_length) { 4 }
  let(:value_range) { 0..5 }
  let(:max_turns) { 12 }

  let(:stdout) { StringIO.new }
  let(:stdin) { double('stdin') }

  describe '.new' do
    subject { described_object }

    it { is_expected.to have_attributes(config:) }
  end

  describe '#start_game' do
    subject(:start_game) { described_object.start_game }

    it 'should announce the beginning of the game' do
      start_game
      expect(stdout.string).to eq(<<~OUTPUT)

        Welcome to Mastermind

        Guess the secret code which contains 4 values

        Each value in the secret code is one of these colors:
        red, blue, green, yellow, orange, or black

        Example guess input:
        red blue green yellow
      OUTPUT
    end
  end

  describe '#create_secret_code' do
    subject { described_object.create_secret_code }

    context 'when a valid secret code is given' do
      it 'should return a Code' do
        expect(stdin).to receive(:gets).and_return("#{secret_code_colors.join(' ')}\n")

        expect(subject).to eq(secret_code)
        expect(stdout.string).to eq("\nEnter the secret code:\n")
      end
    end

    context 'when invalid colors are given' do
      invalid_data = [
        ['gold', 'Error: gold is not a valid color. Please try again.'],
        ['gold silver', 'Error: gold and silver are not valid colors. Please try again.'],
        ['gold silver gray', 'Error: gold, silver, and gray are not valid colors. Please try again.'],
        ['gold gold silver', 'Error: gold and silver are not valid colors. Please try again.']
      ]

      invalid_data.each do |invalid_input, error_message|
        it 'should give an error message and reprompt for the secret code' do
          valid_input = "#{secret_code_colors.join(' ')}\n"
          expect(stdin).to receive(:gets).and_return(invalid_input, valid_input)
          expect(subject).to eq(secret_code)
          expect(stdout.string).to eq("\nEnter the secret code:\n#{error_message}\n\nEnter the secret code:\n")
        end
      end
    end

    context 'when not enough colors are given' do
      it 'should give an error mesage and reprompt for the secret code' do
        invalid_input = 'blue green'
        valid_input = "#{secret_code_colors.join(' ')}\n"
        expect(stdin).to receive(:gets).and_return(invalid_input, valid_input)

        expect(subject).to eq(secret_code)
        expect(stdout.string).to eq(<<~OUTPUT)

          Enter the secret code:
          Error: the code needs to have 4 colors. Please try again.

          Enter the secret code:
        OUTPUT
      end
    end
  end

  describe '#show_board' do
    subject(:show_board) { described_object.show_board(board:) }

    context 'when there are not guesses yet' do
      it 'should output the board noting that no guesses have been entered' do
        show_board

        expect(stdout.string).to eq(<<~OUTPUT)

           ═════ M A S T E R M I N D   B O A R D ══════
          ┌──────┬─────────────────────────────┬───────┐
          │ Turn │ Guess                       │ Match │
          ├──────┴─────────────────────────────┴───────┤
          │     No guesses have been submitted yet     │
          └────────────────────────────────────────────┘
                         Available Colors
           red, blue, green, yellow, orange, and black
        OUTPUT
      end
    end

    context 'when there are two guesses' do
      before do
        board.add_guess(guess: Odin::Mastermind::Code.new(values: [0, 0, 1, 1], code_length:, value_range:))
        board.add_guess(guess: Odin::Mastermind::Code.new(values: [2, 2, 3, 3], code_length:, value_range:))
      end

      it 'should output the board with the two guesses and feedback' do
        show_board

        expect(stdout.string).to eq(<<~OUTPUT)

           ═════ M A S T E R M I N D   B O A R D ══════
          ┌──────┬─────────────────────────────┬───────┐
          │ Turn │ Guess                       │ Match │
          ├──────┼─────────────────────────────┼───────┤
          │    1 │ red    red    blue   blue   │ XO    │
          │    2 │ green  green  yellow yellow │ XO    │
          └──────┴─────────────────────────────┴───────┘
                         Available Colors
           red, blue, green, yellow, orange, and black
        OUTPUT
      end
    end
  end

  describe '#make_guess' do
    subject { described_object.make_guess(board:) }

    context 'when a valid guess is given' do
      it 'should return a Code' do
        guess = %w[red green black blue]
        guess_str = guess.join(' ')
        guess_values = guess.map { |color| colors.index(color) }
        expect(stdin).to receive(:gets).and_return("#{guess_str}\n")

        guess = subject

        expect(guess.values).to eq(guess_values)
        expect(stdout.string).to eq("\nThere are 12 remaining guesses. Enter a guess:\n")
      end
    end
  end

  describe '#announce_winner' do
    subject(:announce_winner) { described_object.announce_winner(board:) }

    context 'when the code maker wins' do
      it 'should announce the that the code maker was the winner' do
        allow(board).to receive(:turns).and_return(Array.new(12))
        allow(board).to receive(:winner).and_return(:code_maker)
        announce_winner
        expect(stdout.string).to eq(<<~OUTPUT)

          The code maker wins after 12 guesses
          The secret code was: red blue green yellow
        OUTPUT
      end
    end

    context 'when the code breaker wins' do
      it 'should announce the that the code breaker was the winner' do
        allow(board).to receive(:turns).and_return(Array.new(8))
        allow(board).to receive(:winner).and_return(:code_breaker)
        announce_winner
        expect(stdout.string).to eq(<<~OUTPUT)

          The code breaker wins after 8 guesses
        OUTPUT
      end
    end
  end

  describe '#show_duplicate_guess_error' do
    subject(:show_error) { described_object.show_duplicate_guess_error(guess:) }
    let(:guess) { Odin::Mastermind::Code.new(values: [0, 1, 2, 3], code_length:, value_range:) }

    it 'prints a duplicate guess error message' do
      show_error
      expect(stdout.string).to eq("\nError: You've already guessed 'red blue green yellow'. Please try again.\n")
    end
  end
end
