require 'set'

class CaveGraph
    
    def initialize(graph_spec)
        # start with an undirected graph specification in ascii form
        ugraph = []
        lines = graph_spec.split("\n")
        lines.each do |line|
            node_a, node_b = line.strip.split('-')
            next if !node_a or !node_b
            ugraph.push([node_a, node_b])
        end
        # Convert the undirecte graph into a directed representation
        @graph = {} # uninitialized key is empty list
        ugraph.each do |edge|
            node_a, node_b = edge
            # initialize non-pre-existing nodes
            @graph[node_a] = Set.new if !@graph[node_a]
            @graph[node_b] = Set.new if !@graph[node_b]
            @graph[node_a].add(node_b)
            @graph[node_b].add(node_a)
        end
    end

    def is_uppercase(node)
        lcbytes = node.each_byte.find_all{|c| c >= 'a'.ord and c <= 'z'.ord}
        return true if lcbytes.size == 0
    end

    def is_revisitable(node, visited_counts)
        # terminal nodes are never revisitable
        return false if node == "start" or node == "end"
        # upper case is always revisitable
        return true if is_uppercase(node)
        # lower case nodes are only revisitable once
        if visited_counts[node] < 2
            other = visited_counts.keys.find{|k| !is_uppercase(k) and visited_counts[k] >= 2}
            return false if other
            return true
        end
        return false
    end

    def find_paths_to_end(current_path, visited_lc_counts)
        paths = []
        current_node = current_path.last
        
        # Update visited counts
        new_visited = visited_lc_counts.clone
        if new_visited[current_node]
            return nil if !is_revisitable(current_node, new_visited)
            new_visited[current_node] += 1
        else
            new_visited[current_node] = 1
        end

        @graph[current_node].each do |neighbor|
            if neighbor=="end"
                paths << current_path+["end"] 
            else
                new_paths = find_paths_to_end(current_path + [neighbor], new_visited)
                if new_paths
                    new_paths.each do |path|
                        paths << path
                    end
                end
            end
        end
        paths
    end
end

inp1 = %q{
    dc-end
    HN-start
    start-kj
    dc-start
    dc-HN
    LN-dc
    HN-end
    kj-sa
    kj-HN
    kj-dc
}

inp2 = %q{
    fs-end
    he-DX
    fs-he
    start-DX
    pj-DX
    end-zg
    zg-sl
    zg-pj
    pj-he
    RW-he
    fs-DX
    pj-RW
    zg-RW
    start-pj
    he-WI
    zg-he
    pj-fs
    start-RW
}

inp3 = %q{
    FK-gc
    gc-start
    gc-dw
    sp-FN
    dw-end
    FK-start
    dw-gn
    AN-gn
    yh-gn
    yh-start
    sp-AN
    ik-dw
    FK-dw
    end-sp
    yh-FK
    gc-gn
    AN-end
    dw-AN
    gn-sp
    gn-FK
    sp-FK
    yh-gc
}

graph = CaveGraph.new(inp3)
# puts graph.find_paths_to_end(["start"], {}).map{|p| p.join("-")}.join("\n")
npaths = graph.find_paths_to_end(["start"], {}).size
puts "There are #{npaths} paths in the graph"