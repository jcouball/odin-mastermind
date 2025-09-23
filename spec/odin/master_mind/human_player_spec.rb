# frozen_string_literal: true

RSpec.describe Odin::Mastermind::HumanPlayer do
  let(:described_object) { described_class.new(name:, config:, game_io:) }

  let(:name) { 'John' }

  let(:board) { Odin::Mastermind::Board.new(secret_code:, max_turns:) }

  let(:secret_code) { Odin::Mastermind::Code.new(values: [1, 2, 3, 4], code_length:, value_range:) }

  let(:config) { Odin::Mastermind::Configuration.new(code_length:, value_range:, max_turns:) }

  let(:code_length) { 4 }
  let(:value_range) { 0..5 }
  let(:max_turns) { 12 }

  let(:game_io) { double('game_io') }

  describe '.new' do
    subject { described_object }

    it { is_expected.to have_attributes(name:, config:, game_io:) }
  end

  describe '#create_secret_code' do
    subject { described_object.create_secret_code }

    let(:secret_code) { Odin::Mastermind::Code.new(values: [1, 2, 3, 4], code_length:, value_range:) }

    before do
      expect(game_io).to receive(:create_secret_code).and_return(secret_code)
    end

    it { is_expected.to eq(secret_code) }
  end

  describe '#make_guess' do
    subject { described_object.make_guess(board:) }

    let(:guess) { Odin::Mastermind::Code.new(values: [5, 5, 5, 5], code_length:, value_range:) }

    before do
      expect(game_io).to receive(:make_guess).and_return(guess)
    end

    it { is_expected.to eq(guess) }
  end
end
