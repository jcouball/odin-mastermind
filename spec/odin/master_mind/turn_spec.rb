# frozen_string_literal: true

RSpec.describe Odin::Mastermind::Turn do
  let(:instance) { described_class.new(guess:, feedback:) }

  let(:secret_code) { Odin::Mastermind::Code.new(values: [1, 2, 3, 4], code_length:, value_range:) }
  let(:guess) { Odin::Mastermind::Code.new(values: [1, 2, 3, 4], code_length:, value_range:) }
  let(:feedback) { Odin::Mastermind::Feedback.new(secret_code:, guess:) }
  let(:code_length) { 4 }
  let(:value_range) { 0..5 }

  describe '.new' do
    subject { instance }

    context 'with valid guess and feedback' do
      it { is_expected.to have_attributes(guess:, feedback:) }
    end
  end
end
