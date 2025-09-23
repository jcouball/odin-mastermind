# frozen_string_literal: true

RSpec.describe Odin::Mastermind::ComputerPlayer do
  let(:described_object) { described_class.new(name:, config:) }

  let(:name) { 'Computer' }

  let(:board) { Odin::Mastermind::Board.new(secret_code:, max_turns:) }

  let(:secret_code) { Odin::Mastermind::Code.new(values: [1, 2, 3, 4], code_length:, value_range:) }

  let(:config) { Odin::Mastermind::Configuration.new(code_length:, value_range:, max_turns:) }

  let(:code_length) { 4 }
  let(:value_range) { 0..5 }
  let(:max_turns) { 12 }

  describe '.new' do
    subject { described_object }

    it { is_expected.to have_attributes(name:, config:) }
  end

  describe '#create_secret_code' do
    subject { described_object.create_secret_code }

    it { is_expected.to be_a(Odin::Mastermind::Code) }
  end

  describe '#make_guess' do
    subject { described_object.make_guess(board:) }

    it { is_expected.to be_a(Odin::Mastermind::Code) }
  end
end
