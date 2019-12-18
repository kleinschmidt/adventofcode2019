using StaticArrays

includet("intcode.jl")
using .Intcodes


directions = [@SVector([0, -1]), # 1 -> N
              @SVector([0, 1]),  # 2 -> S
              @SVector([-1, 0]), # 3 -> W
              @SVector([1, 0])]  # 4 -> E

reverse_direction(d) = findfirst(isequal(-d), directions)

outcomes = Dict(0=>'#', 1=>'.', 2=>'o')

function make_map(n=10000)
    
    input = Channel{Int}()
    output = Channel{Int}()
    brain = Computer(read("15.input", String), input=input, output=output)
    @async run!(brain)

    location = @SVector [0,0]
    tiles = Dict(location => '.')
    reached_from = Dict(location => @SVector([0,0]))

    # strategy is to visit every node in the graph with DFS since that's easy to
    # do with the robot...just need to track which move was taken to reach the
    # node.  then when you run out of unvisited neighbors, you rewind
    for i in 1:n
        print(location, ": ")
        dir = findfirst(i -> !haskey(tiles, location + directions[i]), 1:4)
        # no un-visited neighbors and back at the start, so we're done
        dir === nothing && location == @SVector([0,0]) && break
        dir === nothing && print(" (backtrack) ")
        dir = something(dir, findfirst(isequal(reached_from[location]-location), directions))
        print("move $dir ($(directions[dir])) ")
        put!(input, dir)

        result = take!(output)
        next_location = location + directions[dir]
        tiles[next_location] = outcomes[result]
        println(tiles[next_location])
        if result != 0
            if !haskey(reached_from, next_location)
                reached_from[next_location] = location
            end
            location = next_location
        end
    end
    println("done")

    return tiles
end

function disp(tiles)
    xmin, xmax = extrema(first.(keys(tiles)))
    ymin, ymax = extrema(last.(keys(tiles)))
    for y in ymin:ymax
        for x in xmin:xmax
            print(get(tiles, @SVector([x,y]), ' '))
        end
        println()
    end
end

function distances(tiles, start = @SVector([0,0]))
    distances = Dict(start => 0)
    frontier = [start]

    while !isempty(frontier)
        location = pop!(frontier)
        for dir in 1:4
            next = location + directions[dir]
            if !haskey(distances, next) && tiles[next] != '#'
                pushfirst!(frontier, next)
                distances[next] = distances[location] + 1
            end
        end
    end

    return distances
end

function star1()
    tiles = make_map()
    ds = distances(tiles)
    ds[findfirst(isequal('o'), tiles)]
end

function star2()
    tiles = make_map()
    o2_loc = findfirst(isequal('o'), tiles)
    ds = distances(tiles, o2_loc)
    maximum(values(ds))
end
