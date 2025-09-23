# frozen_string_literal: true

RSpec.describe Odin::Mastermind::CommandLineIO do
  let(:described_object) { described_class.new(config:) }
  let(:config) { Odin::Mastermind::Configuration.new(code_length:, value_range:, max_turns:) }

  let(:secret_code) { Odin::Mastermind::Code.new(values: [1, 2, 3, 4], code_length:, value_range:) }

  let(:board) { Odin::Mastermind::Board.new(secret_code:, max_turns:) }

  let(:code_length) { 4 }
  let(:value_range) { 0..5 }
  let(:max_turns) { 12 }

  describe '.new' do
    subject { described_object }

    it { is_expected.to have_attributes(config:) }
  end

  describe '#start_game' do
    subject { described_object.start_game }

    it 'should raise a NotImplementedError' do
      expect { subject }.to raise_error(NotImplementedError)
    end
  end

  describe '#create_secret_code' do
    subject { described_object.create_secret_code }

    it 'should raise a NotImplementedError' do
      expect { subject }.to raise_error(NotImplementedError)
    end
  end

  describe '#show_board' do
    subject { described_object.show_board(board:) }

    it 'should raise a NotImplementedError' do
      expect { subject }.to raise_error(NotImplementedError)
    end
  end

  describe '#make_guess' do
    subject { described_object.make_guess(board:) }

    it 'should raise a NotImplementedError' do
      expect { subject }.to raise_error(NotImplementedError)
    end
  end

  describe '#announce_winner' do
    subject { described_object.announce_winner(board:) }

    it 'should raise a NotImplementedError' do
      expect { subject }.to raise_error(NotImplementedError)
    end
  end
end
