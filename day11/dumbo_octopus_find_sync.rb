class Grid

    attr_reader :num_flashes

    def initialize(ascii_grid)
        # Parse Ascii Grid into 2 dimensional array
        lines = ascii_grid.split("\n")
        digit_lines = lines.find_all{|l| l =~ /^\d+$/}
        @grid = digit_lines.map do |l| 
            l.scan(/\d/).map{|c| c.to_i}
        end # now an NxN array
        # TODO: assert checks for well formed inputs
        @num_rows = @grid.size
        @num_cols = @grid.first.size

        # Global counter of flashes
        @num_flashes = 0
    end

    # Perform one round of the energy increase / flashing process
    def step

        @flash_queue = []
        @flashed = []

        # Increase energy level of all
        increase_energy()

        # Flash any queued octopi
        while @flash_queue.size > 0
            flash_one()
        end

        # Reset any flashed octopi to 0 energy
        reset_flashed()
    end 

    def increase_one(row_idx, col_idx)
        return if row_idx < 0 or col_idx < 0 or 
            row_idx >= @num_rows or col_idx >= @num_cols

        @grid[row_idx][col_idx] += 1
        tuple = [row_idx, col_idx]
        if @grid[row_idx][col_idx] > 9 and !@flashed.include?(tuple)
            @num_flashes += 1
            @flashed.push(tuple)
            @flash_queue.push(tuple)
        end
    end

    def increase_energy
        (0...@num_rows).each do |row_idx|
            (0...@num_cols).each do |col_idx|
                increase_one(row_idx, col_idx)
            end
        end
    end

    def flash_one
        row_idx, col_idx = @flash_queue.shift
        increase_one(row_idx-1, col_idx)
        increase_one(row_idx+1, col_idx)
        increase_one(row_idx-1, col_idx-1)
        increase_one(row_idx+1, col_idx+1)
        increase_one(row_idx-1, col_idx+1)
        increase_one(row_idx+1, col_idx-1)
        increase_one(row_idx, col_idx-1)
        increase_one(row_idx, col_idx+1)
    end

    def reset_flashed
        @zero_detected = @flashed.size == @num_rows * @num_cols
        @flashed.each do |flashed|
            row_idx, col_idx = flashed
            @grid[row_idx][col_idx] = 0
        end
    end

    def ascii_grid
        @grid.map { |row|
            row.join('')
    }.join("\n")
    end

    def is_zero
        @zero_detected
    end
end

grid = Grid.new(File.read("real.in"))

i = 0
while i < 10000
    i+=1
    grid.step()
    if grid.is_zero()
        puts "After #{i} steps, the grid has completely flashed"
        break
    end
    #puts grid.ascii_grid()
end
