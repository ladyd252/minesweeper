class Game

  def initialize()
    @board = Board.new()
  end

  def play

    until @board.over?
      @board.render
      move
    end

    if @board.won
      puts "Yey! You win!"
    else
      puts "Boo. That was a bomb :("
    end

  end

  def move
    p "Flag or reveal, where would you like to move to?"

    action = gets.scan('/[fr]/')
    position = gets.scan('/[0-9]/')

    tile = @board.tiles[position]

    if action == "f"
      tile.flagged = true
    else
      tile.reveal
    end

  end

end


class Board
  attr_accessor :over, :won, :tiles
  BOARD_SIZE = 9
  BOMB_COUNT = 5

  def initialize
    @over = false
    @won = true
    @board = Array.new(BOARD_SIZE) do |row|
      Array.new(BOARD_SIZE) do |col|
        Tile.new(self, [row, col])
      end
    end

    @board.flatten.sample(BOMB_COUNT).each do |tile_to_bomb|
      tile_to_bomb.bomb
    end
    # @board = Array.new(9) {|array| Array.new(9) {|num| num = 0}}
    # 5.times do
    #   col = rand(9)
    #   row = rand(9)
    #   @board[col][row] = "b"
    # end
    # @tiles = Array.new(9) {|array| Array.new(9) {|num| num = 0}}
    # @board.each_with_index do |array, i|
    #   array.each_with_index do |val, j|
    #     pos = [i, j]
    #     @tiles[i][j] = Tile.new(@board, pos)
    #   end
    # end
  end

  def over?
    counter  = 0
    tiles.each do |array|
      array.each do |tile|
        counter += 1 if tile.revealed
      end
    end
    if counter == 76
      over = true
    end
    over
  end

  def render
    p @tiles
    @tiles.each_with_index do |array, i|
      array.each_with_index do |tile, j|
        if tile.revaled == true
          print tile.neighbors_bomb_count
        elsif tile.flagged == true
          print "f"
        else
          print "*"
        end
      end

      puts ""
    end
  end

end


class Tile

  attr_accessor :revealed, :flagged, :bombed

  def initialize(board, pos)
    @board = board
    @pos = pos
    @revealed = false
    @bombed = false
    @flagged = false
  end

  def inspect
    @pos
  end

  def reveal
    if bomb?
      @board.over = true
      won = false
    else
      revaled = true
      if neighbors_bomb_count == 0
        neighbors.each do |neighbor|
          @board.tiles[neighbor].reveal
        end
      end
    end

    self
  end

  def bomb
    @bombed = true
  end

  def neighbors
    cur_x, cur_y = pos

    moves = [
      [ -1, -1],
      [ -1, 0],
      [ -1, 1],
      [ 0, 1],
      [ 0, -1],
      [ 1, -1],
      [ 1, 0],
      [ 1, 1]
    ]

    valid_moves = []

    moves.each do |(dx, dy)|
      new_pos = [cur_x + dx, cur_y + dy]

      if new_pos.all? { |coord| coord.between?(0, 9) }
        valid_moves << new_pos
      end
    end
    valid_moves
  end

  def neighbors_bomb_count
    count = 0

    neighbors.each do |neighbor|
      tile = Tile.new(@board, neighbor)
      count += 1 if tile.bomb? == true
    end

    count
  end

  def flag
  end
end

#game = Game.new
#game.play
