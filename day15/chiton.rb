require 'set'

def colorize(str, color)
    colors = {
        :black => 30,
        :red => 31,
        :green => 32,
        :yellow => 33,
        :blue => 34
    }
    "\e[#{colors[color]}m" + str + "\e[0m"
end


class WeightedGridGraph
    
    class Point < Array
        def initialize(x,y)
            self[0]=x
            self[1]=y
        end
        def x
            self[0]
        end
        def y
            self[1]
        end
    end

    def initialize(encoded)
        @weights = encoded.split("\n").map do |line|
            line.scan(/\d/).map{|digit| digit.to_i}
        end
        @x_sz = @weights.first.size
        @y_sz = @weights.size
        @meta = {} # metadata about each cell stored here
    end

    # For part 2, the grid is 5 times larger
    def explode()
        lines = (0...@y_sz).each do |y|
            cells = (0...@x_sz).each do |x|
                (0..5).each do |yscale|
                    (0..5).each do |xscale|
                        next if xscale == 0 and yscale == 0
                        ny = @y_sz * yscale + y
                        nx = @x_sz * xscale + x
                        dist = xscale + yscale
                        @weights[ny] ||= []
                        @weights[ny][nx] = (@weights[y][x]+dist-1)%9+1
                    end
                end

            end
        end 
        @x_sz = @x_sz * 5
        @y_sz = @y_sz * 5
    end

    def render
        lines = (0...@y_sz).map do |y|
            cells = (0...@x_sz).map do |x|
                p = Point.new(x,y)
                if block_given?
                    yield(p)
                else
                    weight(p).to_s
                end
            end
            cells.join("")
        end
        lines.join("\n")
    end

    def weight(p)
        @weights[p.y][p.x]
    end

    def dist(a,b)
        Math.sqrt( (a.x - b.x)**2 + (a.y - b.y)**2 )
    end

    def neighbors(p)
        n = []
        n << Point.new(p.x-1,p.y) if p.x - 1 >= 0
        n << Point.new(p.x+1,p.y) if p.x + 1 < @x_sz
        n << Point.new(p.x,p.y-1) if p.y - 1 >= 0
        n << Point.new(p.x,p.y+1) if p.y + 1 < @y_sz
        n
    end

    def top_left
        Point.new(0,0)
    end

    def bottom_right
        Point.new(@x_sz-1, @y_sz-1)
    end
end

module AStar
    class State < Struct.new(:node, :cost, :dist, :via); end

    def shortest_path(start, finish, draw=true)
        @candidates = [State.new(start,0,0,nil)]
        @completed = {}
        count = 0 
        end_state = nil 
        while @candidates.size > 0
            candidate = @candidates.shift
            draw_state(candidate) if draw and count % 50 == 0 
            count += 1
            if candidate.node == finish
                end_state = candidate
                break
            end
            neighbors(candidate.node).each do |neighbor|
                newcost = candidate.cost + weight(neighbor)
                newdist = dist(neighbor, finish)
                maybe_insert_state(State.new(neighbor, newcost, newdist, candidate.node))
            end
            @completed[candidate.node] = candidate
        end
        if end_state 
            puts "Solved!: iters=#{count}, end_state => #{end_state.inspect}, path => #{reconstruct_path(end_state).inspect}, cost => #{end_state.cost}"
            draw_state(end_state)
        end
    end

    def maybe_insert_state(state)
        return if @completed[state.node]
        existing = @candidates.find{|c| c.node == state.node}
        if existing
            if existing.cost <= state.cost
                return
            end
            existing.cost = state.cost
            existing.via = state.via
        else
            @candidates << state
        end
        @candidates.sort! do |a,b|
            a.dist + a.cost <=> b.dist + b.cost
            # a.cost <=> b.cost
        end
    end

    def reconstruct_path(state)
        nodes = [state.node]
        while state.via != nil
            nodes << state.via
            state = @completed[state.via]
        end
        nodes.reverse
    end

    def draw_state(state)
        best_path = reconstruct_path(state)
        graph = render() do |p|
            color = :black 
            color = :blue if @completed[p]
            color = :yellow if @candidates.find{|c| c.node == p}
            color = :green if best_path.include?(p)
            w = weight(p).to_s
            w = "X" if w == ""
            colorize(w,color)
        end
        puts graph
        # sleep(0.000001)
    end
end

grid = WeightedGridGraph.new(File.read("real.in"))
grid.extend(AStar)
# grid.explode()

puts grid.shortest_path(grid.top_left, grid.bottom_right)
