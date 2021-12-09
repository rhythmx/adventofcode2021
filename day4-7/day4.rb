require 'irb'

input   = File.read(ARGV.first)
inputs  = input.split("\n\n")
numbers = inputs.shift.split(/,/).map{|s| s.to_i}
boards  = inputs.map{|b| b.scan(/\d+/m).map{|s| s.to_i}.each_slice(5).to_a}
checks  = boards.map{|b| b+b.transpose}

def count_moves(lines, numbers)
  numbers.each_with_index do |ball, idx|
    lines.each do |line| 
      if line.include?(ball)
        line.delete(ball)
        if line.size() == 0
          return idx
        end
      end
    end
  end
  nil
end

counts = (0...checks.size()).map{|idx| [idx,count_moves(checks[idx], numbers)]}
counts.sort!{ |a,b| a[1] <=> b[1] }
if true
  # only difference between first and second problem variants
  counts.reverse!
end
winner = boards[counts.first[0]]
puts winner.flatten.inject(0){ |s,n| s + n } * numbers[counts.first[1]]
