# frozen_string_literal: true

require_relative 'mastermind/board'
require_relative 'mastermind/code'
require_relative 'mastermind/feedback'
require_relative 'mastermind/turn'
require_relative 'mastermind/version'

module Odin
  module Mastermind
    # Raised when a guess is made after the game is over
    class GameOverError < StandardError; end
  end
end
