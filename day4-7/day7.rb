# Input: 16,1,2,0,4,2,7,1,2,14

# [0, 1, 1, 2, 2, 2, 4, 7, 14, 16], +0, -0, avg 4.9 [7 vs 3]

# [0, 1, 1, 2, 2, 2, 4, 6, 13, 15], +0, -1, avg 4.6 [7 vs 3]

# [0, 1, 1, 2, 2, 2, 4, 5, 12, 14], +0, -2, avg 4.3 [7 vs 3]

# [0, 1, 1, 2, 2, 2, 4, 4, 11, 13], +0, -3, avg 4.0 [8 vs 2]

# [0, 1, 1, 2, 2, 2, 4, 4, 10, 12], +0, -4, avg 3.8 [6 vs 4]

# [0, 1, 1, 2, 2, 2, 3, 3,  9, 11], +0, -5, avg 3.4 [6 vs 4]

# [0, 1, 1, 2, 2, 2, 2, 2,  8, 10], +0, -6, avg 3.0 [8 vs 2]


def average(list)
  list.inject(0){ |sum,n| sum+n} / list.length.to_f
end

# Read comma delimited list of integers from user specified file
hpositions = File.read(ARGV.first).scan(/\d+/).map{ |str| str.to_i }.sort


def iterate_towards_optimal(hpositions)
  avg = average(hpositions)


  inflection = hpositions.bsearch_index{ |pos| pos > avg}

  if( inflection )
    if (inflection > hpositions.size()/2.0)
      (inflection...hpositions.size()).each do |idx|
        hpositions[idx] -= 1 if hpositions[idx] != avg
      end
    else
      (0...inflection).each do |idx|
        hpositions[idx] += 1 if hpositions[idx] != avg
      end
    end
  end
  hpositions
end

oldpos = hpositions.clone
newpos = iterate_towards_optimal(hpositions.clone)
while(newpos != oldpos)
  oldpos = newpos
  newpos = iterate_towards_optimal(newpos.clone)
end

optimal_pos = newpos[0]


def calc_fuel(hpositions,optimal)
  hpositions.inject(0) { |sum,pos| d=(pos - optimal).abs + sum }
end

def calc_fuel_b(hpositions,optimal)
  hpositions.inject(0) { |sum,pos| d=(pos - optimal).abs; d*(d+1)/2 + sum }
end

puts "fuel: " + calc_fuel(hpositions, optimal_pos).to_s

fuel_pos = (hpositions.min..hpositions.max).map{ |pos| [pos,calc_fuel_b(hpositions,pos)] }.sort{ |a,b| a[1]<=>b[1]}[0][0]

puts "fuel_pos: " + fuel_pos.inspect + " : " + calc_fuel_b(hpositions, fuel_pos).to_s
