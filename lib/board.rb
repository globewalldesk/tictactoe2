# The Board class will have just one object. Its purpose is to print the
# board and update the spaces. It should probably have the AI methods too--
# so this is probably the biggest class.
class Board
  attr_accessor :spaces, :triads, :ctoken, :ptoken
  def initialize
    create_spaces # nine board slots, ID'd from upper left, rightward then down
    create_triads # the eight combinations of 3-in-a-rows on the board
  end

  def create_spaces
    @spaces = [] # each space is an object; @spaces is an array of those objects
    9.times do |i|
      @spaces[i] = Space.new(i) # the @spaces index matches the .i attribute
    end
  end

  def create_triads
    @triads = [] # array of triads, q.v.
    number_array = # array of array indexes, for building triads
      [ [0,1,2], [3,4,5], [6,7,8], [0,3,6],
        [1,4,7], [2,5,8], [0,4,8], [2,4,6] ]
    number_array.each do |triple|
      x, y, z = triple
      @triads << Triad.new(x, y, z, @spaces)
    end
  end

  # Determine if computer and player are X and O, or O and X
  def assign_tokens(who_goes_first)
     @ptoken, @ctoken = (who_goes_first == "computer" ? ["O", "X"] : ["X", "O"] )
  end

  # generic method to display the current board
  def display
    find_and_mark_winning_triad(@ptoken) # so winning spaces are printed green
    find_and_mark_winning_triad(@ctoken)
    puts " ┏━━━━━━━┳━━━━━━━┳━━━━━━━┓"
    puts " ┃       ┃       ┃       ┃"
    print " ┃   "
    spaces[0].print_s
    print "   ┃   "
    spaces[1].print_s
    print "   ┃   "
    spaces[2].print_s
    print "   ┃\n"
    puts " ┃       ┃       ┃       ┃"
    puts " ┣━━━━━━━╋━━━━━━━╋━━━━━━━┫"
    puts " ┃       ┃       ┃       ┃"
    print " ┃   "
    spaces[3].print_s
    print "   ┃   "
    spaces[4].print_s
    print "   ┃   "
    spaces[5].print_s
    print "   ┃\n"
    puts " ┃       ┃       ┃       ┃"
    puts " ┣━━━━━━━╋━━━━━━━╋━━━━━━━┫"
    puts " ┃       ┃       ┃       ┃"
    print " ┃   "
    spaces[6].print_s
    print "   ┃   "
    spaces[7].print_s
    print "   ┃   "
    spaces[8].print_s
    print "   ┃\n"
    puts " ┃       ┃       ┃       ┃"
    puts " ┗━━━━━━━┻━━━━━━━┻━━━━━━━┛"
  end

  def find_and_mark_winning_triad(token)
    @triads.each do |triad|
      collected_spaces = [] # build array of triad spaces
      token_count = 0 # counts token matches
      # each "triad" is a triad object
      triad.index.keys.each do |i|
        if @spaces[i].c == token
          token_count += 1
          collected_spaces << @spaces[i]
        end
      end
      if token_count == 3
        # marks "winner" attribute of each space true if triad is a winner
        collected_spaces.each { |space| space.winner = true}
      end
    end
  end

  # The big AI, borrowed from Wikipedia via Stack Overflow; test if a move is
  # generated by any of these tests; one should be by the end of the method.
  # The original AI shouldn't be able to be beaten.
  def computer_moves(winnable)
    skip_rule = determine_rule_to_skip(winnable)
    puts "The computer moved:"

    # Test each set of conditions, until a move is found
    move = false
    1.times do
      # Win: If you have two in a row, play the third to get three in a row.
      # puts "Trying 1"
      move, length = are_there_two_tokens_in_a_row(@ctoken) unless skip_rule == 0
      break if move # skip to end if move is found

      # Block: If the opponent has two in a row, play the third to block them.
      # puts "Trying 2"
      move, length = are_there_two_tokens_in_a_row(@ptoken) unless skip_rule == 1
      break if move

      # Fork: Create an opportunity where you can win in two ways (a fork).
      # puts "Trying 3"
      move = discover_fork(@ctoken) unless skip_rule == 2
      break if move

      # Block Opponent's Fork: If opponent can create fork, block that fork.
      # puts "Trying 4"
      move = discover_fork(@ptoken) unless skip_rule == 3
      break if move

      # Center: Play the center.
      # puts "Trying 5"
      # Note, no "unless skip_rule == 4" here. This is because if it's the opening
      # move, and this rule is skipped, then the computer won't play anything.
      move = 4 if @spaces[4].c == " " # if the center is open, move there
      break if move

      # Opposite Corner: If the opponent is in the corner, play the opposite corner.
      # puts "Trying 6"
      move = try_opposite_corner unless skip_rule == 5
      break if move

      # Empty Corner: Play an empty corner.
      # puts "Trying 7"
      move = try_empty_corner
      break if move

      # Empty Side: Play an empty side.
      # puts "Trying 8"
      move = play_empty_side

      # If move is still false, game is over!

    end # of "do" block

    # Make the change to @spaces; this edits the individual space and hence also
    # the triads and the board, which use it.
    @spaces[move].c = @ctoken if move

  end # of computer_moves

  def determine_rule_to_skip(winnable)
    skip_rule = ""
    if winnable == 'y'
      skip_rule = [0, 1, 2, 3, 5].sample # randomly chooses a rule to "forget"
    end
    return skip_rule
  end

  # Examines all triads to see if any have two tokens and an empty; if so,
  # then it's a winning move.
  def are_there_two_tokens_in_a_row(token)
    groovy = [] # array of winning moves
    # Strategy: since there is already an array of all triads, simply process
    # the array; for each triad, test if it contains two tokens and one " ".
    # If so, return the index for that space.
    @triads.each do |triad|
      tokens_spotted = 0 # count the tokens
      empty_spotted = false # look for an empty spot
      empty = nil # any empty space
      # triad.index is a hash of spaces, with keys = indexes
      triad.index.each do |index, space|
        # i.e., increment the tokens_spotted if a space in the triad
        # contains the token
        tokens_spotted += 1 if space.c == token
        if space.c == " "
          # incrementing not necessary for spotting an empty; we just need one
          empty_spotted = true
          empty = space.i # assign the index to that of the current space
        end
        # The essential logic: if you spot an empty space in a triad, along with
        # two computer tokens, then add the empty space to the array of groovies!
        if empty_spotted == true && tokens_spotted == 2
          groovy << empty
        end
      end
    end # of examination of board
    return groovy.sample, groovy.length if ! groovy.empty?
    false # if no conditions are met, return false
  end

  # Test each empty space: suppose it is filled in, then test if there are two
  # ways to satisfy are_there_two_tokens_in_a_row. If yes, move in the empty!
  def discover_fork(token)
    open_spaces = compile_open_spaces
    # Cycle through open_spaces; temporarily add a token to spaces;
    # then determine if there are two instances of two computer tokens
    # in a row.
    avail = [] # array of fork-creating spaces, to maximize randomness of play
    open_spaces.each do |space|
      # assigns computer token to this empty space
      space.c = token
      # check if spaces now contains a fork (meaning length > 1)!
      afork, length = are_there_two_tokens_in_a_row(token)
      space.c = " "
      # add index to array of indexes of fork-creating spaces, if there is a fork
      avail << space.i if length && length > 1
    end
    if ! avail.empty? # do this if there ARE available fork-creating spaces
      corners = avail.select {|x| [0, 2, 6, 8].include?(x)}
      return corners.sample if ! corners.empty? # gimme any corner blocker first
      return avail.sample # then other kinds of blockers
    end
    false # return if no forks were found
  end

  # returns a list of spaces array indexes that == " "
  def compile_open_spaces
    # Compile list of open spaces
    index = 0
    open_spaces = []
    @spaces.each do |space|
      open_spaces << space if space.c == " "
      index += 1
    end
    return open_spaces
  end

  # Check to see if player has chosen a corner that has an open opposite.
  def try_opposite_corner
    # Check for player corner moves; then check if opposite is open; return if so
    avail = []
    avail << 8 if @spaces[0].c == @ptoken && @spaces[8].c == " "
    avail << 0 if @spaces[8].c == @ptoken && @spaces[0].c == " "
    avail << 2 if @spaces[6].c == @ptoken && @spaces[2].c == " "
    avail << 6 if @spaces[2].c == @ptoken && @spaces[6].c == " "
    return avail.sample if ! avail.empty?
    return false # if you can't jump on an opposite corner
  end

  # Simply occupy any empty corner
  def try_empty_corner
    avail = [] # create array of empty corners
    avail << 0 if @spaces[0].c == " "
    avail << 2 if @spaces[2].c == " "
    avail << 6 if @spaces[6].c == " "
    avail << 8 if @spaces[8].c == " "
    return avail.sample if ! avail.empty? # sample the empty corner array
    return false # if all corners are occupied
  end

  # Simply occupy any empty side
  def play_empty_side
    avail = []
    avail << 1 if @spaces[1].c == " "
    avail << 3 if @spaces[3].c == " "
    avail << 5 if @spaces[5].c == " "
    avail << 7 if @spaces[7].c == " "
    return avail.sample if ! avail.empty?
    return false # if all sides are occupied
  end

  def player_moves
    puts "Your turn."
    valid_answer = nil
    answer = ""
    # Prepare array of acceptable spaces (i.e., Space objects)
    open_spaces = compile_open_spaces
    open_indexes = []
    open_spaces.each do |space|
      open_indexes << space.i
    end
    until valid_answer do
      print "Place an #{@ptoken}: "
      answer = gets.chomp.to_i
      if ! (1..9).to_a.include?(answer)
        puts "Please choose a number, 1 through 9."
        next
      end
      if open_indexes.include?(answer - 1)
        valid_answer = true
      else
        puts "An '#{@spaces[answer - 1].c}' is already in that spot. Try again."
      end
    end
    # Actually write player's move to board!
    @spaces[answer - 1].c = @ptoken
  end

  # Determine if there's a winner
  def determine_if_there_is_a_winner
    if three_in_a_row(@ptoken) == true
      puts "Player wins this game!"
      return false, "player"
    elsif three_in_a_row(@ctoken) == true
      puts "Computer wins this game!"
      return false, "computer"
    elsif compile_open_spaces.length == 0
      puts "Drawn game!"
      return false, "drawn"
    else
      return true # i.e., true that the game's not won yet
    end
  end

  # are there three in a row yet?
  def three_in_a_row(token)
    @triads.each do |triad|
      token_count = 0 # counts token matches
      # each "triad" is a triad object
      triad.index.keys.each do |i|
        token_count += 1 if @spaces[i].c == token
      end
      if token_count == 3
        return true
      end
    end
    false # return false if not three in a row yet
  end

end

#===============================================================================

# Spaces are the nine numbered slots that make up the Tic-Tac-Toe board.
# Each Space is initialized with both its numbered index (i) and its content.
# There will be at least one method, viz., to print the content (this will
# be used in the board) of its space.
class Space
  attr_accessor :i, :c, :winner
  def initialize(i)
    @i = i # This corresponds to the index in the spaces array
    @c = " " # This is the space's content--initially, an empty space
    @winner = nil # Space is specially printed because it's in a winning triad
  end

  # Used by Board#display, this method simply prints, with formatting, the
  # content of the submitted space.
  def print_s
    # NOTEthis will allow the printing of a space on a colored background if
    # it is a winner.
    if @c == " "
      print "#{@i+1}".red
    elsif (@c != " " && @winner == true)
      print @c.on_green
    else
      print @c
    end
  end

end

#===============================================================================

# Triads are three spaces that, if all X's or all O's, represent a winning state
# for the board. There are eight triads. Special methods are used to check
# things about triads for the AI & determining a winner. The "index" attribute
# is a hash, with keys being indexes and values being corresponding space objects.
class Triad
  attr_accessor :index
  def initialize(x, y, z, spaces)
    @index = {} # each triad has three indexes; to list #s, use triad.index.keys
    # this takes x, y, z values and matches triad keys to spaces
    [x,y,z].each do |s|
      @index[s] = spaces[s]
    end
  end
end