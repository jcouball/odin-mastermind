# frozen_string_literal: true

module Odin
  module Mastermind
    Configuration = Struct.new(:code_length, :value_range, :max_turns, keyword_init: true)
  end
end
