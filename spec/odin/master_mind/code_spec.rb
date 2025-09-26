# frozen_string_literal: true

RSpec.describe Odin::Mastermind::Code do
  let(:described_object) { described_class.new(values:, code_length:, value_range:) }

  let(:values) { Array.new(code_length) { possible_values.sample } }
  let(:code_length) { 4 }
  let(:value_range) { 0..5 }
  let(:possible_values) { value_range.to_a }

  describe '.new' do
    subject { described_object }
    it { is_expected.to be_a(described_class) }
    it { is_expected.to have_attributes(values:, code_length:, value_range:) }

    it 'should duplicate and freeze the values array' do
      expect(subject.values.object_id).not_to eq(values.object_id)
      expect(subject.values).to be_frozen
    end

    context 'code_length is not valid' do
      let(:values) { [1, 2, 3, 4] }

      context 'when code_length is not a integer' do
        let(:code_length) { 'string' }
        it 'should raise a TypeError' do
          expect { subject }.to raise_error(TypeError, 'Expected code_length to be an Integer but it was a String')
        end
      end

      context 'when code_length is not positive' do
        [-1, 0].each do |invalid_length|
          context "with a value of #{invalid_length}" do
            let(:code_length) { invalid_length }

            it 'raises an ArgumentError' do
              expect { subject }.to(
                raise_error(ArgumentError, "Expected code_length to be positive but was #{invalid_length}")
              )
            end
          end
        end
      end
    end

    context 'value_range not valid' do
      context 'when value_range is not a range' do
        let(:values) { [0, 0, 0, 0] }
        let(:value_range) { 'not a range' }

        it 'should raise a TypeError' do
          expect { subject }.to raise_error(TypeError, 'Expected value_range to be a Range but it was a String')
        end
      end

      context 'when value_range is not iterable' do
        let(:values) { [0, 0, 0, 0] }
        let(:value_range) { (0.0..10.0) }

        it 'should raise an ArgumentError' do
          expect { subject }.to raise_error(ArgumentError, 'Expected value_range to be iterable')
        end
      end
    end

    context 'when values is not valid' do
      context 'when values is not an array' do
        let(:values) { 'not an array' }
        it 'should raise a TypeError' do
          expect { subject }.to raise_error(TypeError, 'Expected values to be an Array but it was a String')
        end
      end

      context 'when values.length is not equal to code_length' do
        let(:values) { [1] }
        it 'should raise an ArgumentError' do
          expect { subject }.to raise_error(ArgumentError, 'Expected values.length to be 4 but was 1')
        end
      end

      context 'when a value class is not compatible with the value_range' do
        let(:values) { ['not an integer', 0, 0, 0] }
        it 'should raise an ArgumentError' do
          expect { subject }.to raise_error(ArgumentError, 'All values must be of type Integer and within the range')
        end
      end

      context 'when a value is not within the value_range' do
        let(:values) { [6, 0, 0, 0] }
        it 'should raise an ArgumentError' do
          expect { subject }.to raise_error(ArgumentError, 'All values must be of type Integer and within the range')
        end
      end
    end
  end

  describe '#<=>' do
    subject { described_object <=> other }

    context 'when other has the same values' do
      let(:other) { described_class.new(values:, code_length:, value_range:) }
      it { is_expected.to eq(0) }
    end

    context 'when other is less than' do
      let(:other) { described_class.new(values: [0, 0, 0, 0], code_length:, value_range:) }
      it { is_expected.to eq(1) }
    end

    context 'when other is greater than' do
      let(:other) { described_class.new(values: [5, 5, 5, 5], code_length:, value_range:) }
      it { is_expected.to eq(-1) }
    end

    context 'when other is not a Code' do
      let(:other) { 'not a Code' }
      it { is_expected.to eq(nil) }
    end
  end

  describe '#hash' do
    subject { described_object.hash }
    it 'should be the hash of the values' do
      expect(subject).to eq(described_object.values.hash)
    end
  end
end
