# frozen_string_literal: true

require 'odin/mastermind/random_guessing_strategy'
require 'odin/mastermind/code'

RSpec.describe Odin::Mastermind::RandomGuessingStrategy do
  let(:described_object) { described_class.new(code_length:, value_range:) }
  let(:code_length) { 4 }
  let(:value_range) { 0..5 }

  describe '.new' do
    subject { described_object }

    it { is_expected.to have_attributes(code_length:, value_range:) }
  end

  describe '#next_guess' do
    subject(:guess) { described_object.next_guess(board:) }

    # This strategy does not use board
    let(:board) { double('board') }

    it 'returns a Code object' do
      expect(guess).to be_a(Odin::Mastermind::Code)
    end

    it 'returns a code with the correct code_length and value_range' do
      expect(guess).to have_attributes(code_length:, value_range:)
    end
  end
end
