# frozen_string_literal: true

require 'odin/mastermind/random_guessing_strategy'
require 'odin/mastermind/code'

RSpec.describe Odin::Mastermind::KnuthGuessingStrategy do
  let(:described_object) { described_class.new(code_length:, value_range:) }

  let(:code_length) { 4 }
  let(:value_range) { 0..5 }

  let(:max_turns) { 12 }

  describe '.new' do
    subject { described_object }

    it { is_expected.to have_attributes(code_length:, value_range:) }
  end

  describe '#next_guess' do
    subject(:guess) { described_object.next_guess(board:) }

    let(:board) { Odin::Mastermind::Board.new(secret_code:, max_turns:) }
    let(:secret_code) { Odin::Mastermind::Code.new(values: [0, 1, 2, 3], code_length:, value_range:) }

    context 'for the first turn' do
      it 'returns the standard initial guess of [0, 0, 1, 1]' do
        expect(guess.values).to eq([0, 0, 1, 1])
      end

      context 'when the value_range allows for only one choice' do
        let(:value_range) { 1..1 }
        let(:secret_code) { Odin::Mastermind::Code.new(values: [1, 1, 1, 1], code_length:, value_range:) }

        it 'returns the standard initial guess of [1]' do
          expect(guess.values).to eq([1, 1, 1, 1])
        end
      end
    end

    context 'for a subsequent turn' do
      before do
        # This is the standard first guess made by this class
        first_guess = Odin::Mastermind::Code.new(values: [0, 0, 1, 1], code_length:, value_range:)

        # The feedback for this guess 1 exact, 1 partial
        board.add_guess(guess: first_guess)
      end

      it 'prunes candidates and returns the next logical guess' do
        # The algorithm should now have pruned its list of 1296 possible codes
        # down to the much smaller set that matches the (1 exact, 1 partial) feedback.

        # We expect it to make a specific next guess to eliminate the most
        # possibilities.
        expect(guess.values).to eq([0, 0, 2, 3])
      end
    end
  end

  describe '#choose_next_guess' do
    subject { described_object.send(:choose_next_guess, unused_codes: dummy_unused_codes) }
    let(:dummy_unused_codes) { Set[] } # Not important for this test, can be empty

    context 'when at least one of the best guesses are possible secret codes' do
      let(:best_guesses) do
        Set[
          # The .min of this set is [2, 2, 2, 2]
          Odin::Mastermind::Code.new(values: [3, 3, 3, 3], code_length:, value_range:),
          Odin::Mastermind::Code.new(values: [2, 2, 2, 2], code_length:, value_range:)
        ]
      end

      let(:possible_secret_codes) do
        Set[
          Odin::Mastermind::Code.new(values: [0, 0, 0, 0], code_length:, value_range:),
          Odin::Mastermind::Code.new(values: [1, 1, 1, 1], code_length:, value_range:),
          Odin::Mastermind::Code.new(values: [3, 3, 3, 3], code_length:, value_range:)
        ]
      end

      before do
        # Force #select_best_guesses to return our predefined set.
        allow(described_object).to receive(:select_best_guesses).and_return(best_guesses)

        # Force the list of possible codes to be our other predefined set.
        described_object.instance_variable_set(:@possible_secret_codes, possible_secret_codes)
      end

      it 'returns the lowest-valued guess the intersection of best_guesses and possible_secret_codes' do
        expected_guess = Odin::Mastermind::Code.new(values: [3, 3, 3, 3], code_length:, value_range:)
        expect(subject).to eq(expected_guess)
      end
    end

    context 'when none of the best guesses are possible secret codes' do
      # SETUP: Define two distinct sets of codes.
      let(:best_guesses) do
        Set[
          # The .min of this set is [2, 2, 2, 2]
          Odin::Mastermind::Code.new(values: [3, 3, 3, 3], code_length:, value_range:),
          Odin::Mastermind::Code.new(values: [2, 2, 2, 2], code_length:, value_range:)
        ]
      end

      let(:possible_secret_codes) do
        Set[
          Odin::Mastermind::Code.new(values: [0, 0, 0, 0], code_length:, value_range:),
          Odin::Mastermind::Code.new(values: [1, 1, 1, 1], code_length:, value_range:)
        ]
      end

      before do
        # 1. Force #select_best_guesses to return our predefined set.
        allow(described_object).to receive(:select_best_guesses).and_return(best_guesses)

        # 2. Force the list of possible codes to be our other predefined set.
        described_object.instance_variable_set(:@possible_secret_codes, possible_secret_codes)
      end

      it 'returns the lowest-valued guess from the best_guesses' do
        # EXPECTATION: The result should be the minimum code from the `best_guesses` set.
        expected_guess = Odin::Mastermind::Code.new(values: [2, 2, 2, 2], code_length:, value_range:)
        expect(subject).to eq(expected_guess)
      end
    end
  end
end
