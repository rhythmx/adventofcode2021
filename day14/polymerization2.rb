
class Polymerizer

    attr_accessor :template

    def initialize(encoded)
        lines = encoded.split("\n")

        @template_str = nil
        @insertions = {}

        lines.each do |line|
            case line
            when /([A-Z]{4,})/
                @template_str = $1
            when /([A-Z]{2}) -> ([A-Z]+)/
                @insertions[$1] = $2
            end
        end

        @template = Hash.new(0)
        idx = 0
        while idx < @template_str.size - 1
            @template[@template_str[idx] + @template_str[idx+1]] += 1
            idx += 1 
        end 

        @val_counts = Hash.new(0)
        @template_str.each_byte do |b|
            @val_counts[b.chr] += 1
        end
    end

    def step()
        # pp @template
        pairs = @template.keys
        old_template = @template.clone
        pairs.each do |pair|
            count = old_template[pair]
            if count > 0
                new_c = @insertions[pair]
                if new_c
                    pair1 = pair[0] + new_c
                    pair2 = new_c + pair[1]
                    @template[pair1] += count
                    @template[pair2] += count
                    @template[pair]  -= count
                    @val_counts[new_c] += count
                end
            end
        end 
    end

    def maxmin()
        counts = @val_counts.keys.map{|k| @val_counts[k]}
        # pp @val_counts
        counts.max - counts.min
    end

end

poly = Polymerizer.new(File.read("real.in"))
niter = 40 # 10 for part 1
#puts poly.template.to_s
niter.times { poly.step }
puts "After #{niter} steps, maxmin = #{poly.maxmin}"
