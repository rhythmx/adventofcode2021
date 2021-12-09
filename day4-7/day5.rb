# 2d array of integers representing presense of 0 or more lines
class Map
  def initialize(x,y)
    @x_size = x
    @y_size = y
    @map = (0...@x_size).map{(0...@y_size).map{0}}
  end

  # Dump the map to screen
  def draw
    screen_map = @map.transpose
    (0...@x_size).each do |x|
      (0...@y_size).each do |y|
        print (screen_map[x][y] > 0) ? screen_map[x][y] : '.'
        print " "
      end
      print "\n"
    end
  end

  def raster_line(line)

    if line.vertical?
      x1,x2 = [line.a.x, line.b.x].sort
      (x1..x2).each do |x|
        @map[x][line.a.y] = @map[x][line.a.y].next
      end
    elsif line.horizontal?
      y1,y2 = [line.a.y, line.b.y].sort
      (y1..y2).each do |y|
        @map[line.a.x][y] = @map[line.a.x][y].next
      end
    else
      xs = if line.a.x > line.b.x
             (line.b.x..line.a.x).to_a.reverse
           else
             (line.a.x..line.b.x).to_a
           end
      ys = if line.a.y > line.b.y
             (line.b.y..line.a.y).to_a.reverse
           else
             (line.a.y..line.b.y).to_a
           end
      puts xs.zip(ys).inspect
      xs.zip(ys).each do |x,y| 
        @map[x][y] = @map[x][y].next
      end
    end
  end

  def points_with_2_or_more_intersects
    @map.flatten.find_all{ |i| i >= 2 }.size()
  end
end

# Handy data structures
class Point < Struct.new(:x, :y); end
class Line < Struct.new(:a, :b)
  def horizontal?
    a.x == b.x
  end
  def vertical?
    a.y == b.y
  end
  def diagonal?
    (a.y - b.y).abs == (a.x - b.x).abs
  end
end

# Initialize the map
map = Map.new(1000,1000)
# map.draw()

# Pull in input file
input_file = ARGV.first || raise("No file given")
input = File.read(input_file)

# Parse all x1,y1 -> x2,y2 line entries
lines = input.split("\n").map do |line_entry|
  points_ary = line_entry.split(/\s*->\s*/).map do |point_entry|
    point_ary = point_entry.split(",").map{ |s| s.to_i}
    Point.new(*point_ary)
  end
  Line.new(*points_ary)
end

problem_two = true

if !problem_two
  # find all horizonal or vertical lines
  hvlines = lines.find_all { |l| l.horizontal? or l.vertical? }
  # Draw all lines
  hvlines.each do |l|
    map.raster_line(l)
  end
  puts map.points_with_2_or_more_intersects
else
  # find all horizonal or vertical lines
  hvdlines = lines.find_all { |l| l.horizontal? or l.vertical? or l.diagonal? }
  # Draw all lines
  hvdlines.each do |l|
    map.raster_line(l)
  end
  map.draw()
  puts map.points_with_2_or_more_intersects
end
