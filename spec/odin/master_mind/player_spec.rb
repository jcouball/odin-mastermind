# frozen_string_literal: true

RSpec.describe Odin::Mastermind::Player do
  let(:described_object) { described_class.new(name:, config:) }
  let(:name) { 'John' }
  let(:config) { double('config') }

  describe '.new' do
    subject { described_object }

    it { is_expected.to have_attributes(name:, config:) }
  end

  describe '#create_secret_code' do
    subject { described_object.create_secret_code }

    it 'should raise an NotImplementedError' do
      expect { subject }.to raise_error NotImplementedError
    end
  end

  describe '#make_guess' do
    subject { described_object.make_guess(board:) }
    let(:board) { double }

    it 'should raise an NotImplementedError' do
      expect { subject }.to raise_error NotImplementedError
    end
  end
end
