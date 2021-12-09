# Pull in the input
lanternfish = File.read(ARGV.first).scan(/\d+/).map{ |str| str.to_i }

# puts "Initial state: "  + lanternfish_timers.inspect

# iterate for N days
#(1..80).each do |day|

fishbins = (0..8).map { 0 }

lanternfish.each do |timer_val|
  fishbins[timer_val] += 1
end

(1..256).each do |day| 

  spawners = fishbins.shift # the zero values
  fishbins << spawners # new fish added to the 8 slot
  fishbins[6] += spawners # six slot gets the timer resets

  puts "after #{day} days: " + fishbins.inject(0){ |sum,num| sum+num }.to_s

end



# sort n*log(n) +
# n/8 * 2 pushes
# log(n)
