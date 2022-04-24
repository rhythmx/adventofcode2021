class Input

    attr_reader :max_x, :max_y
    attr_reader :points, :folds

    def initialize(encoded)
        lines = encoded.split("\n")
        # note the maximum coordinates in order to size the board
        @max_x = 0
        @max_y = 0
        @points = []
        @folds = []
        # parse all insn lines
        lines.each do |line|
            case line
            when /(\d+),(\d+)/
                x = $1.to_i
                y = $2.to_i
                @max_x = [@max_x,x].max
                @max_y = [@max_y,y].max
                @points << [x,y]
            when /fold along (x|y)=(\d+)/
                @folds << [$1, $2.to_i]
            else 
                puts line
            end
        end    
    end

    def points_fold_y(y_line)
        @max_y = [y_line, @max_y - y_line].max - 1
        points = []
        @points.each do |x,y|
            if y != y_line
                points << [x, -(y-y_line).abs + @max_y + 1]
            end
        end
        @points = points
    end

    def points_fold_x(x_line)
        @max_x = [x_line, @max_x - x_line].max - 1
        points = []
        @points.each do |x,y|
            if x != x_line
                points << [- (x-x_line).abs + @max_x + 1, y]
            end
        end
        @points = points
    end

    def grid
        grid = Grid.new(@max_x+1,@max_y+1)
        @points.each do |x,y|
            grid.set(x,y,"#")
        end
        grid
    end
end

class Grid
    def initialize(x,y)
        @x_sz = x
        @y_sz = y
        @grid = (0...x).map {
            Array.new(y,'.')
        }
    end

    def to_s
        (0...@y_sz).map do |y|
            (0...@x_sz).map do |x|
                get(x,y)
            end.join("")
        end.join("\n")
    end

    def set(x,y,val)
        @grid[x][y] = val
    end

    def get(x,y)
        @grid[x][y]
    end

    def visible_count 
        count = 0
        (0...@y_sz).each do |y|
            (0...@x_sz).each do |x|
                count += 1 if get(x,y) == "#"

            end
        end
        count
    end

end

input = Input.new(File.read("real.in"))

# Part 1
if false
    input.folds[0..0].each do |dir,pos|
        puts "#{dir}=#{pos}"
       if dir == 'y'
           input.points_fold_y(pos)
       elsif dir == 'x'
           input.points_fold_x(pos)
       end
       break
    end
    puts "The number of visible after one operation is #{input.grid.visible_count}"
end

# Part2 
input.folds.each do |dir,pos|
    puts "#{dir}=#{pos}"
   if dir == 'y'
       input.points_fold_y(pos)
   elsif dir == 'x'
       input.points_fold_x(pos)
   end
   puts input.grid
end

