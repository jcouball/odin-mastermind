# frozen_string_literal: true

RSpec.describe Odin::Mastermind::GameEngine do
  let(:described_object) { described_class.new(code_maker:, code_breaker:, game_io:, config:) }

  let(:code_maker) { Odin::Mastermind::ComputerPlayer.new(name: 'Computer', config:) }
  let(:code_breaker) { Odin::Mastermind::HumanPlayer.new(name: 'Human', config:, game_io:) }
  let(:game_io) { Odin::Mastermind::CommandLineIO.new(config:) }

  let(:config) { Odin::Mastermind::Configuration.new(code_length:, value_range:, max_turns:) }

  let(:code_length) { 4 }
  let(:value_range) { 0..5 }
  let(:max_turns) { 3 } # Normally 12 turns are allowed, but for testing we will make it 3 turns

  describe '.new' do
    subject { described_object }

    it { is_expected.to have_attributes(code_breaker:, code_maker:, game_io:, config:, board: nil) }
  end

  describe '#run' do
    subject(:run_game) { described_object.run }

    let(:secret_code) { Odin::Mastermind::Code.new(values: [1, 2, 3, 4], code_length:, value_range:) }

    context 'the code breaker wins in 2 moves' do
      let(:guesses) do
        [
          Odin::Mastermind::Code.new(values: [1, 1, 2, 2], code_length:, value_range:),
          Odin::Mastermind::Code.new(values: [1, 2, 3, 4], code_length:, value_range:)
        ]
      end

      before do
        allow(game_io).to receive(:start_game)
        allow(game_io).to receive(:show_board)
        allow(code_maker).to receive(:create_secret_code).and_return(secret_code)
        allow(code_breaker).to receive(:make_guess).and_return(*guesses)
      end

      it 'should end the game with the code breaker as winner' do
        expect(game_io).to receive(:announce_winner).with(board: an_instance_of(Odin::Mastermind::Board))

        run_game

        expect(described_object.board.winner).to eq(:code_breaker)
        expect(described_object.board.turns.length).to eq(2)
      end
    end

    context 'the code maker wins after 3 moves' do
      let(:guesses) do
        [
          Odin::Mastermind::Code.new(values: [1, 1, 1, 1], code_length:, value_range:),
          Odin::Mastermind::Code.new(values: [2, 2, 2, 2], code_length:, value_range:),
          Odin::Mastermind::Code.new(values: [3, 3, 3, 3], code_length:, value_range:)
        ]
      end

      before do
        allow(game_io).to receive(:start_game)
        allow(game_io).to receive(:show_board)
        allow(code_maker).to receive(:create_secret_code).and_return(secret_code)
        allow(code_breaker).to receive(:make_guess).and_return(*guesses)
      end

      it 'should end the game with the code maker as winner' do
        expect(game_io).to receive(:announce_winner).with(board: an_instance_of(Odin::Mastermind::Board))

        run_game

        expect(described_object.board.winner).to eq(:code_maker)
        expect(described_object.board.turns.length).to eq(3)
      end
    end
  end
end
