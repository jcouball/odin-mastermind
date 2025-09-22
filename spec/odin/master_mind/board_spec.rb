# frozen_string_literal: true

RSpec.describe Odin::Mastermind::Board do
  let(:instance) { described_class.new(secret_code:, max_turns:) }

  let(:secret_code) { Odin::Mastermind::Code.new(values: secret_code_values, code_length:, value_range:) }
  let(:secret_code_values) { [1, 2, 3, 4] }
  let(:code_length) { 4 }
  let(:value_range) { 0..5 }
  let(:max_turns) { 3 } # Normally this is 12, but for testing I am cranking this down

  describe '.new' do
    subject { instance }

    it { is_expected.to have_attributes(secret_code:, turns: [], max_turns:) }
  end

  describe '#add_guess' do
    let(:guesses) do
      [
        Odin::Mastermind::Code.new(values: [1, 1, 2, 2], code_length:, value_range:),
        Odin::Mastermind::Code.new(values: [1, 2, 3, 3], code_length:, value_range:)
      ]
    end

    context 'after adding one turn' do
      before do
        instance.add_guess(guess: guesses[0])
      end

      it 'should create a turn and add it to the turns attribute' do
        expect(instance.turns.length).to eq(1)
        expect(instance.turns[0]).to be_a Odin::Mastermind::Turn
        expect(instance.turns[0].guess).to eq(guesses[0])
        expect(instance.turns[0].feedback).to have_attributes(exact_matches: 1, partial_matches: 1)
      end
    end

    context 'after adding two turns' do
      before do
        instance.add_guess(guess: guesses[0])
        instance.add_guess(guess: guesses[1])
      end

      it 'should create the two turns and add them to the turns attribute' do
        expect(instance.turns.length).to eq(2)
        expect(instance.turns[0].guess).to eq(guesses[0])
        expect(instance.turns[1].guess).to eq(guesses[1])
      end
    end

    context 'after the game is over' do
      let(:guesses) do
        [
          Odin::Mastermind::Code.new(values: [1, 1, 2, 2], code_length:, value_range:),
          Odin::Mastermind::Code.new(values: [1, 2, 3, 4], code_length:, value_range:)
        ]
      end

      before do
        guesses.each { |guess| instance.add_guess(guess:) }
      end

      it 'should raise an Odin::Mastermind::GameOverError' do
        guess = Odin::Mastermind::Code.new(values: [1, 2, 3, 4], code_length:, value_range:)
        expect { instance.add_guess(guess:) }.to raise_error(Odin::Mastermind::GameOverError, 'The game is over')
      end
    end
  end

  describe '#game_over?' do
    subject { instance.game_over? }

    context 'when there have been no guesses' do
      it { is_expected.to eq(false) }
    end

    context 'when the secret code has NOT been guessed and there were less than max_turns guesses' do
      let(:guesses) do
        [
          Odin::Mastermind::Code.new(values: [1, 1, 2, 2], code_length:, value_range:),
          Odin::Mastermind::Code.new(values: [1, 2, 3, 3], code_length:, value_range:)
        ]
      end

      before do
        guesses.each { |guess| instance.add_guess(guess:) }
      end

      it { is_expected.to eq(false) }
    end

    context 'when the secret code has been guessed' do
      let(:guesses) do
        [
          Odin::Mastermind::Code.new(values: [1, 1, 2, 2], code_length:, value_range:),
          Odin::Mastermind::Code.new(values: [1, 2, 3, 4], code_length:, value_range:)
        ]
      end

      before do
        guesses.each { |guess| instance.add_guess(guess:) }
      end

      it { is_expected.to eq(true) }
    end

    context 'when the secret code has not been guessed and there are max_turns guesses' do
      let(:guesses) do
        [
          Odin::Mastermind::Code.new(values: [1, 1, 1, 1], code_length:, value_range:),
          Odin::Mastermind::Code.new(values: [2, 2, 2, 2], code_length:, value_range:),
          Odin::Mastermind::Code.new(values: [3, 3, 3, 3], code_length:, value_range:)
        ]
      end

      before do
        guesses.each { |guess| instance.add_guess(guess:) }
      end

      it { is_expected.to eq(true) }
    end
  end

  describe '#winner' do
    subject { instance.winner }

    context 'when there have been no guesses' do
      it { is_expected.to be_nil }
    end

    context 'when the secret code has NOT been guessed and there were less than max_turns guesses' do
      let(:guesses) do
        [
          Odin::Mastermind::Code.new(values: [1, 1, 2, 2], code_length:, value_range:),
          Odin::Mastermind::Code.new(values: [1, 2, 3, 3], code_length:, value_range:)
        ]
      end

      before do
        guesses.each { |guess| instance.add_guess(guess:) }
      end

      it { is_expected.to be_nil }
    end

    context 'when the secret code has been guessed' do
      let(:guesses) do
        [
          Odin::Mastermind::Code.new(values: [1, 1, 2, 2], code_length:, value_range:),
          Odin::Mastermind::Code.new(values: [1, 2, 3, 4], code_length:, value_range:)
        ]
      end

      before do
        guesses.each { |guess| instance.add_guess(guess:) }
      end

      it { is_expected.to eq(:code_breaker) }
    end

    context 'when the secret code has not been guessed and there are max_turns guesses' do
      let(:guesses) do
        [
          Odin::Mastermind::Code.new(values: [1, 1, 1, 1], code_length:, value_range:),
          Odin::Mastermind::Code.new(values: [2, 2, 2, 2], code_length:, value_range:),
          Odin::Mastermind::Code.new(values: [3, 3, 3, 3], code_length:, value_range:)
        ]
      end

      before do
        guesses.each { |guess| instance.add_guess(guess:) }
      end

      it { is_expected.to eq(:code_maker) }
    end
  end
end
