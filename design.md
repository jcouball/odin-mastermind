# Mastermind Design

Since the domain is pretty well known, I will do a little up-front design and then
use a inside-out TDD to implement the game.

## Domain

* Possible Code Peg colors: %i[red blue green yellow orange black]
* Alternate Code Peg colors for color blind people: %i[blue orange yellow black white
  magenta]

* Configuration
  * code_length: the number of integers in the Code (default is 4)
  * value_range: the possible values for each integer in the Code (default is [0..5])
  * max_turns: the number of turns the code_break has to guess the secret_code

* GameEngine
  * Knows how to:
    * ask the code_maker for a secret_code and adds it to the Board
    * manage the game loop:
      * ask the code_breaker for a guess and the code_maker for feedback and then
        adds it to the Board
      * it asks the Board if the game is over
  * has a Configuration object
  * has a code_maker: a Player who makes the code and gives feedback on the
    code_breaker’s guesses each turn
  * has a code_breaker: a Player trying to guess the code set by the code_maker
  * has a board: the Board stores the state of the game

* Code
  * an ordered set of integer values defined by code_length and value_range
  * secret_code: a Code set by the code_maker that the code_breaker needs to guess
  * guess: a Code given by the code_breaker as a guess to the secret_code

* Player
  * has a name attribute

* Board
  * has a secret_code
  * has an ordered set of Turns (1st turn, 2nd turn, etc.)

* Turn
  * has a guess which is a Code submitted by the code_breaker
  * has a Feedback on that guess which is given by the code_maker

* Feedback
  * The number of values in a guess that exactly or partially match the secret_code
  * Is initialized with a guess and a secret_code and calculates the number of exact
    and partial matches upon initialization
  * How exact and partial matches are calculated:
    * Each value from the guess can only be counted once: it is either an exact
      match, a partial match or not a match to a value in the secret_code
    * Each value from the secret_code can only be matched once
    * Exact matches are evaluated first
    * An exact match is when a value from the guess matches the value from the
      secret_code in the same position
    * A partial match is when a previously unmatched value from the guess matches a
      previously unmatched value from the secret_code

## Design

The implementation will be separated into distinct layers:

* GameIO:
  * Handles all IO to the user
  * There might be specific classes for command line, web, etc.
  * Maps to/from values in the Code to colors to display to the user

* Player
  * Has subclasses for HumanPlayer and ComputerPlayer
  * A human player is given a GameIO to interact with the user
  * Can be asked to submit a secret_code
  * Can be asked to submit a guess (given the array of turns to reference)

* GameEngine:
  * Knows how to run the game: gets the code from the code_maker, accepts guesses
    from the code_breaker, gets feedback from the code_maker, and determines when the
    game is over.
  * Has a GameIO (passed in via the initializer)
  * Has a code_maker Player (passed in via the initializer)
  * Has a code_breaker Player (passed in via the initializer)
  * Has a Board

* Board:
  * Has an array of Turns
  * Knows how to determine if the game is over and its outcome:
    * When a guess exactly matches the secret_code, the game is over and the
      code_breaker wins.
    * When the number of turns reaches max_turns and the final guess is not an exact
      match, the game is over and the code_maker wins.

* Turn
  * Has a guess submitted by the code_breaker
  * Has feedback submitted by the code_maker
