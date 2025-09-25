# frozen_string_literal: true

RSpec.describe Odin::Mastermind::CommandLineIO do
  let(:described_object) { described_class.new(config:, stdout:, stdin:) }
  let(:config) { Odin::Mastermind::Configuration.new(code_length:, value_range:, max_turns:) }

  let(:secret_code_values) { [0, 1, 2, 3] }
  let(:secret_code) { Odin::Mastermind::Code.new(values: secret_code_values, code_length:, value_range:) }
  let(:secret_code_colors) { secret_code_values.map { |value| Odin::Mastermind::CommandLineIO::COLORS[value] } }

  let(:board) { Odin::Mastermind::Board.new(secret_code:, max_turns:) }

  let(:code_length) { 4 }
  let(:value_range) { 0..5 }
  let(:max_turns) { 12 }

  let(:stdout) { double('stdout') }
  let(:stdin) { double('stdin') }

  describe '.new' do
    subject { described_object }

    it { is_expected.to have_attributes(config:) }
  end

  describe '#start_game' do
    subject { described_object.start_game }

    it 'should announce the beginning of the game' do
      expect(stdout).to receive(:puts).with("Welcome to Mastermind\n")
      subject
    end
  end

  describe '#create_secret_code' do
    subject { described_object.create_secret_code }

    context 'when a valid secret code is given' do
      it 'should return a Code' do
        expect(stdout).to receive(:puts).with('Enter the secret code:')
        expect(stdin).to receive(:gets).and_return("#{secret_code_colors.join(' ')}\n")

        expect(subject.values).to eq(secret_code.values)
      end
    end

    context 'when invalid colors are given' do
      invalid_data = [
        ['gold', 'Error: gold is not a valid color. Please try again.'],
        ['gold silver', 'Error: gold and silver are not valid colors. Please try again.'],
        ['gold silver gray', 'Error: gold, silver, and gray are not valid colors. Please try again.']
      ]

      invalid_data.each do |invalid_input, error_message|
        it 'should give an error message and reprompt for the secret code' do
          valid_input = "#{secret_code_colors.join(' ')}\n"

          allow(stdout).to receive(:puts).with('Enter the secret code:')
          expect(stdout).to receive(:puts).with(error_message)
          expect(stdin).to receive(:gets).and_return(invalid_input, valid_input)

          expect(subject.values).to eq(secret_code.values)
        end
      end
    end

    context 'when not enough colors are given' do
      it 'should give an error mesage and reprompt for the secret code' do
        allow(stdout).to receive(:puts).with('Enter the secret code:')
        expect(stdout).to receive(:puts).with('Error: the code needs to have 4 colors. Please try again.')

        invalid_input = 'blue green'
        valid_input = "#{secret_code_colors.join(' ')}\n"
        expect(stdin).to receive(:gets).and_return(invalid_input, valid_input)

        expect(subject.values).to eq(secret_code.values)
      end
    end
  end

  describe '#show_board' do
    subject(:show_board) { described_object.show_board(board:) }

    context 'when there are not guesses yet' do
      it 'should output the board noting that no guesses have been entered' do
        expected_output_lines = <<~OUTPUT.split("\n")
          M A S T E R M I N D   B O A R D
          Turn  Guess                        Match
          ----  ---------------------------  -----
          No guesses have been submitted yet
        OUTPUT
        expected_output_lines.each { |line| expect(stdout).to receive(:puts).with(line) }

        show_board
      end
    end

    context 'when there are two guesses' do
      before do
        board.add_guess(guess: Odin::Mastermind::Code.new(values: [0, 0, 1, 1], code_length:, value_range:))
        board.add_guess(guess: Odin::Mastermind::Code.new(values: [2, 2, 3, 3], code_length:, value_range:))
      end

      it 'should output the board with the two guesses and feedback' do
        expected_output_lines = <<~OUTPUT.split("\n")
          M A S T E R M I N D   B O A R D
          Turn  Guess                        Match
          ----  ---------------------------  -----
            01  red    red    blue   blue    XO
            02  green  green  yellow yellow  XO
        OUTPUT
        expected_output_lines.each { |line| expect(stdout).to receive(:puts).with(line) }

        show_board
      end
    end
  end

  describe '#make_guess' do
    subject { described_object.make_guess(board:) }

    context 'when a valid guess is given' do
      it 'should return a Code' do
        expect(stdout).to receive(:puts).with('There are 12 remaining guesses. Enter a guess:')
        guess = %w[red green black blue]
        guess_str = guess.join(' ')
        guess_values = guess.map { |color| Odin::Mastermind::CommandLineIO::COLORS.index(color) }

        expect(stdin).to receive(:gets).and_return("#{guess_str}\n")

        expect(subject.values).to eq(guess_values)
      end
    end
  end

  describe '#announce_winner' do
    subject { described_object.announce_winner(board:) }

    context 'when the code maker wins' do
      it 'should announce the that the code maker was the winner' do
        allow(board).to receive(:turns).and_return(Array.new(12))
        allow(board).to receive(:winner).and_return(:code_maker)
        expect(stdout).to receive(:puts).with('The code maker wins after 12 guesses')

        expect { subject }.not_to raise_error
      end
    end

    context 'when the code breaker wins' do
      it 'should announce the that the code breaker was the winner' do
        allow(board).to receive(:turns).and_return(Array.new(8))
        allow(board).to receive(:winner).and_return(:code_breaker)
        expect(stdout).to receive(:puts).with('The code breaker wins after 8 guesses')

        expect { subject }.not_to raise_error
      end
    end
  end
end
