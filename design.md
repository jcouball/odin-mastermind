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

## An algorithm for computing Mastermind guesses

This gem implements Donald Knuth's algorithm for computing Mastermind guesses. It is
copied from [this StackExchange
article](https://puzzling.stackexchange.com/questions/546/clever-ways-to-solve-mastermind)
and turned into a step-by-step solution.

1. Create the set `all_possible_codes` of 1296 possible codes, 1111,1112,.., 6666.

2. Create the set `possible_secret_codes` which starts off as a copy of
   `all_possible_codes`. This set will need to be persisted between turns.

3. Start with initial `guess` 1122.

4. Play the `guess` to get the feedback of exact and partial matches.

5. If the feedback is four exact matches the game is won, the algorithm terminates.

6. Remove any codes from `possible_secret_codes` which would not give the same
   feedback for `guess`.

7. Create the set `unused_codes` which is the codes from `all_possible_codes` that
   have not been already been played in the game.

8. Calculate the minimax score for each `unused_code` as follows:

   1. Get feedback for using the `unused_code` as a guess for each
      `possible_secret_code`
   2. Tally the count of each feedback combination (each combination of exact/partial
      matches -- there are 14 different combinations)
   3. The score for each feedback combination is the size of `possible_secret_codes`
      minus the number tallied for that feedback combination. This is the number of
     `possible_secret_codes` that would be eliminated from this guess.
   4. The minimax score of the `unused_code` is the minimum score for all feedback
      combinations

9. Create the set `possible_next_guesses` which is all the codes from `unused_codes`
   tied for high score

10. If there exists one or more guess from `possible_next_guesses` which is in also
    in `possible_secret_codes`, then choose the guess with the lowest value as the
    next `guess`. Otherwise, chose the code from `possible_next_guesses` with the
    lowest value as the next `guess`

11. Repeat from step 4
