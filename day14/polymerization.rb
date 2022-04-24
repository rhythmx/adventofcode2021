require 'pp'
require 'irb'

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

        @template = List.new()
        @template_str.each_byte do |b|
            @template.append(b.chr)
        end

        binding.irb
    end

    def step()
        @template.each_pair do |pair|
            @insertions[pair]
        end
    end

end

class Node
    attr_accessor :val,:next

    def initialize(val)
        @val = val
        @next = nil
    end
end

class List

    def initialize
        @head = nil
        @tail = nil
        @val_counts = Hash.new(0)
    end

    def append(val)
        @val_counts[val] += 1 
        node = Node.new(val)
        if @tail
            @tail.next = node
            @tail = node
        else
            @head = @tail = node
        end
    end

    def each_pair(&block)
        node = @head

        while node and node.next
            old_next = node.next
            # called block will return any insertion operation required
            insert = yield(node.val+node.next.val)
            if insert
                @val_counts[insert] += 1 
                new_node = Node.new(insert)
                node.next = new_node
                new_node.next = old_next
            end
            node = old_next
        end
    end

    def to_s
        node = @head
        retstr = ""
        while node
            retstr += node.val
            node = node.next
        end
        retstr
    end

    def maxmin()
        counts = @val_counts.keys.map{|k| @val_counts[k]}
        pp @val_counts
        counts.max - counts.min
    end

end

poly = Polymerizer.new(File.read("real.in"))
niter = 40 # 10 for part 1
puts poly.template.to_s
niter.times { poly.step }
puts "After #{niter} steps, maxmin = #{poly.template.maxmin}"
