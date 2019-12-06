# graph of "orbits"...how deep is each node?

test_input = """
    COM)B
    B)C
    C)D
    D)E
    E)F
    B)G
    G)H
    D)I
    E)J
    J)K
    K)L
    """

function parse_input(input)
    orbits = Dict{String,Vector{String}}()
    for line in split(chomp(input), '\n')
        center, body = split(line, ')')
        push!(get!(orbits, center, String[]), body)
    end
    orbits, 
end

depths(orbits) = depths(orbits, "COM", 0)

function depths(orbits, body, depth)
    if haskey(orbits, body)
        return depth + sum(depths.(Ref(orbits), orbits[body], depth+1))
    else
        return depth
    end
end


orbits = parse_input(read("06.input", String))

depths(orbits)

