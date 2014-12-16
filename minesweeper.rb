require 'yaml'

class Game

  def initialize
    @board = Board.new
    nil
  end

  def play
    if !load_game
      until @board.over?
        @board.render
        save
        move
      end

      if @board.won
        puts "Yey! You win!"
      else
        puts "Boo. That was a bomb :("
      end
    end
  end

  def move
    p "Flag or reveal, where would you like to move to?"
    answer = gets
    action = answer.scan(/[fr]/).first
    position = answer.scan(/[0-9]/).map(&:to_i)

    tile = @board.board[position[0]][position[1]]

    if action == "f"
      tile.flagged = tile.flagged == true ? false : true
    else
      tile.reveal
    end
  end

  def save
    puts "Would you like to save your current progess?(y/n)"

    answer = gets.scan(/[yn]/).first
    if answer == "y"
      puts "Enter filename: (.yml)"
      filename = gets.chomp

      File.open("#{filename}", "w") {|f| f.write self.to_yaml }
    end
  end

  def load_game

    puts "Would you like to load a previous game?(y/n)"

    answer = gets.chomp
    if answer == "y"

      puts "What is the filename"
      filename = gets.chomp

      YAML.load_file("#{filename}").play
      return true
    end
    false
  end

end


class Board
  attr_accessor :over, :won, :board
  BOARD_SIZE = 9
  BOMB_COUNT = 9

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

    nil
  end

  def over?
    return true if @over == true
    counter  = 0
    @board.each do |array|
      array.each do |tile|
        counter += 1 if tile.revealed
      end
    end
    if counter == BOARD_SIZE * BOARD_SIZE - BOMB_COUNT
      over = true
    end

    over
  end

  def render
    @board.each_with_index do |array, i|
      array.each_with_index do |tile, j|
        if tile.revealed == true
          print "#{tile.neighbors_bomb_count}  "
        elsif tile.flagged == true
          print "f  "
        else
          print "*  "
        end
      end
      puts ""
    end
    nil
  end

  def render_solution
    @board.each_with_index do |array, i|
      array.each_with_index do |tile, j|
        if tile.bombed == true
          print "b  "
        else
          print "*  "
        end
      end
      puts ""
    end
    nil
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
  end

  def reveal
    if @bombed
      @board.over = true
      @board.won = false
    else
      @revealed = true
      if neighbors_bomb_count == 0
        neighbors.each do |neighbor|
          neigh_tile = @board.board[neighbor[0]][neighbor[1]]
          neigh_tile.reveal if neigh_tile.revealed == false && neigh_tile.flagged == false
        end
      end
    end

    nil
  end

  def bomb
    @bombed = true
  end

  def neighbors
    cur_x, cur_y = @pos

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

      if new_pos.all? { |coord| coord.between?(0, 8) }
        valid_moves << new_pos
      end
    end

    valid_moves
  end

  def neighbors_bomb_count
    count = 0

    neighbors.each do |neighbor|
      tile = @board.board[neighbor[0]][neighbor[1]]
      count += 1 if tile.bombed == true
    end

    count
  end

end

game = Game.new
game.play
