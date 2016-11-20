require 'colorize'
require './lib/game'
require './lib/board'

#===============================================================================

session = Session.new # A session is a set of games

# Outer loop (multiple games)
while session.running
  game = Game.new # Initializes the present game
  game.startup_thang # Welcome, etc.
  session.ask_if_winnable # Does the player want to be able to win?
  board = Board.new # Make a new board!
  game.determine_who_goes_first(board) # Flip a coin; board needed for drawing
  board.assign_tokens(game.who_goes_first) # Assigns "X" to whoever goes first

#===============================================================================

  # Inner loop (present game)
  while game.not_won_yet
    # This weird process results in the player's last move displayed on top,
    # then the computer's most recent move, prompting the player's next move.
    unless game.who_goes_first == "player"
      # move, toggle who moves, and display result
      board.computer_moves(session.winnable)
      board.display
      # look at board for a winner; if found, assign not_won_yet is false
      game.not_won_yet, game.winner = board.determine_if_there_is_a_winner
    end
    break if game.not_won_yet == false
    board.player_moves
    system("cls")
    # look at board for a winner; if found, assign not_won_yet is false
    puts "You moved:"
    board.display
    game.not_won_yet, game.winner = board.determine_if_there_is_a_winner
    game.who_goes_first = nil
  end # of inner loop

#===============================================================================

  session.increment_score(game.winner) # increments score based on game.winner
  session.announce_score
  session.wanna_play_again

end # of outer loop (multiple games)
