
# The wrapper that controls the whole set of games the user may play.
# Counts number of wins/losses and whether the session is currently_running.
class Session
  attr_accessor :running, :winnable, :player_score, :computer_score, :drawn_games
  # Simply initializes the variables associated with the session.
  def initialize
    @running = true # becomes false when player exits program
    @player_score = 0
    @computer_score = 0
    @drawn_games = 0
  end

  def ask_if_winnable
    @winnable ||= nil # on script startup, initialize for "unless" check (next)
    unless @winnable # don't check winnability every time
      print "Do you want the game to be winnable? (y/n) "
      @winnable = gets.chomp
      if @winnable == 'y'
        win_msg = "OK, game will (sometimes) be winnable."
        puts win_msg
        puts "=" * win_msg.length
      else
        ok_msg = "OK, the best you'll be able to get is a draw."
        puts ok_msg
        puts "=" * ok_msg.length
        @winnable == 'n' # set it to a consistent alternative if non-'y'
      end
    end
  end

  def increment_score(winner)
    if winner == "player"
      @player_score += 1
    elsif winner == "computer"
      @computer_score += 1
    else
      @drawn_games += 1
    end
  end

  def announce_score
    puts "Score is:"
    puts "  Player: #{@player_score}"
    puts "  Computer: #{@computer_score}"
    puts "  Drawn games: #{@drawn_games}\n"
  end

  def wanna_play_again
    answer = ""
    until answer == 'y' || answer == 'n'
      print "Another game? (y)es or (n)o: "
      answer = gets.chomp
      puts "Only y or n, please." unless answer == 'y' or answer == 'n'
      puts "OK, so long!" if answer == 'n'
    end
    @running = (answer == 'y' ? true : false)
  end

end

#===============================================================================

# Each individual match, winnable by getting three in a row. This simply has
# the game control logic.
class Game
  attr_accessor :not_won_yet, :winner, :who_goes_first
  def initialize
    @not_won_yet = true # game begins by not being won
    @winner = nil # no winner until there's a winner
  end

  def startup_thang
    system("cls")
    welcome = "Starting a new game of Tic-Tac-Toe!"
    puts "=" * welcome.length
    puts welcome
    puts "=" * welcome.length
  end

  def determine_who_goes_first(board)
    @who_goes_first = (rand > 0.5) # outputs random "true" or "false"
    @who_goes_first = (@who_goes_first == true ? "computer" : "player")
    board.display if @who_goes_first == "player"
    puts "#{@who_goes_first.capitalize} goes first."
    puts "=" * "#{@who_goes_first.capitalize} goes first.".length
  end

end
