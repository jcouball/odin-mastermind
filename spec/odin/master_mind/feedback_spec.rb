# frozen_string_literal: true

RSpec.describe Odin::Mastermind::Feedback do
  let(:described_object) { described_class.new(secret_code:, guess:) }

  let(:code_length) { 4 }
  let(:value_range) { 0..5 }

  let(:secret_code) { Odin::Mastermind::Code.new(values: secret_code_values, code_length:, value_range:) }
  let(:guess) { Odin::Mastermind::Code.new(values: guess_values, code_length:, value_range:) }

  describe '.new' do
    subject { described_object }

    context 'when the guess has no values in common with the secret code' do
      let(:secret_code_values) { [0, 1, 2, 3] }
      let(:guess_values)       { [4, 5, 4, 5] }

      it { is_expected.to have_attributes(exact_matches: 0, partial_matches: 0) }
    end

    context 'when all guess values are correctly placed (a winning guess)' do
      let(:secret_code_values) { [0, 1, 2, 3] }
      let(:guess_values)       { [0, 1, 2, 3] }

      it { is_expected.to have_attributes(exact_matches: 4, partial_matches: 0) }
    end

    context 'when all guess values are present but incorrectly placed' do
      let(:secret_code_values) { [0, 1, 2, 3] }
      let(:guess_values)       { [3, 2, 1, 0] }

      it { is_expected.to have_attributes(exact_matches: 0, partial_matches: 4) }
    end

    context 'when some values are correctly placed and others are incorrectly placed' do
      let(:secret_code_values) { [0, 1, 2, 3] }
      let(:guess_values)       { [0, 1, 3, 2] }

      it 'correctly counts both exact and partial matches' do
        expect(subject).to have_attributes(exact_matches: 2, partial_matches: 2)
      end
    end

    context 'when a guess with duplicate values matches a unique value in the secret code' do
      let(:secret_code_values) { [0, 1, 2, 3] }
      let(:guess_values)       { [0, 1, 1, 1] }

      it 'counts the matched value from the secret code only once' do
        expect(subject).to have_attributes(exact_matches: 2, partial_matches: 0)
      end
    end

    context 'when the secret code has duplicates and the guess has unique values' do
      let(:secret_code_values) { [0, 1, 1, 1] }
      let(:guess_values)       { [0, 1, 2, 3] }

      it 'matches guess values to the available pegs in the secret code' do
        expect(subject).to have_attributes(exact_matches: 2, partial_matches: 0)
      end
    end

    context 'when duplicates exist in both the secret code and the guess' do
      let(:secret_code_values) { [1, 1, 2, 3] }
      let(:guess_values)       { [1, 4, 1, 1] }

      it 'correctly prioritizes exact matches before finding partials for the remaining pegs' do
        expect(subject).to have_attributes(exact_matches: 1, partial_matches: 1)
      end
    end

    context 'when an exactly matched peg is no longer available for partial matching' do
      let(:secret_code_values) { [0, 1, 1, 1] }
      let(:guess_values)       { [0, 0, 0, 0] }

      it 'prioritizes the exact match and does not count any partial matches for that peg' do
        expect(subject).to have_attributes(exact_matches: 1, partial_matches: 0)
      end
    end

    context 'when an exact match and a partial match come from the same guess value' do
      let(:secret_code_values) { [0, 1, 1, 1] }
      let(:guess_values)       { [1, 1, 2, 3] }

      it 'counts one as exact and the other as partial using available code pegs' do
        expect(subject).to have_attributes(exact_matches: 1, partial_matches: 1)
      end
    end
  end
  describe '#==' do
    subject { described_object == other }

    let(:secret_code_values) { [0, 1, 2, 3] }

    # For other -- for testing they will have the same secret_code
    let(:other_guess) { Odin::Mastermind::Code.new(values: other_guess_values, code_length:, value_range:) }
    let(:other) { described_class.new(secret_code:, guess: other_guess) }

    context 'when the other object has the same exact and partial match counts' do
      let(:guess_values)       { [0, 1, 3, 2] } # 2 exact, 2 partial matches
      let(:other_guess_values) { [1, 0, 2, 3] } # 2 exact, 2 partial matches

      it { is_expected.to be true }
    end

    context 'when the other object has different exact match counts' do
      let(:guess_values)       { [0, 1, 2, 3] } # 4 exact, 0 partial matches
      let(:other_guess_values) { [0, 1, 2, 5] } # 3 exact, 0 partial matches

      it { is_expected.to be false }
    end

    context 'when the other object has different partial match counts' do
      let(:guess_values)       { [0, 1, 3, 2] } # 2 exact, 2 partial matches
      let(:other_guess_values) { [0, 1, 5, 5] } # 2 exact, 0 partial matches

      it { is_expected.to be false }
    end

    context 'when the other object is not a Feedback object' do
      let(:guess_values) { [0, 1, 2, 3] } # doesn't matter what this is
      let(:other) { 'not a Feedback' }

      it { is_expected.to be false }
    end
  end
end
