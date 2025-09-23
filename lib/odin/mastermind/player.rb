# frozen_string_literal: true

module Odin
  module Mastermind
    # A mastermind player with a name
    #
    # @abstract Subclass and override {#create_secret_code} and {#make_guess}
    #
    class Player
      # @param name [String] the player's name
      # @param config [Configuration] the game configuration
      #
      def initialize(name:, config:)
        @name = name
        @config = config
      end

      # @return [String] the player's name
      attr_reader :name

      # @return [Configuration] the game configuration
      attr_reader :config

      # Subclasses must implement #create_secret_code
      #
      # @abstract
      #
      # @return [Code] the secret code created by the player
      #
      def create_secret_code
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      # Subclasses must implement #make_guess
      #
      # @abstract
      #
      # @param board [Board] the current game board
      #
      # @return [Code] the guess made by the player
      #
      def make_guess(board:)
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end
    end
  end
end
