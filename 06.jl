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
    parents = Dict{String,String}()
    for line in split(chomp(input), '\n')
        center, body = split(line, ')')
        push!(get!(orbits, center, String[]), body)
        parents[body] = center
    end
    orbits, parents
end

depths(orbits) = depths(orbits, "COM", 0)

function depths(orbits, body, depth)
    if haskey(orbits, body)
        return depth + sum(depths.(Ref(orbits), orbits[body], depth+1))
    else
        return depth
    end
end

orbits, parents = parse_input(read("06.input", String))

depths(orbits)

function path_to(body, parents)
    path = String[]
    while body in keys(parents)
        body = parents[body]
        push!(path, body)
    end
    return reverse!(path)
end

function n_shared_prefix(a, b)
    min_len = min(length(a), length(b))
    for n in 1:min_len
        a[n] != b[n] && return n-1
    end
    return min_len
end

function star2(parents)
    you_path = path_to("YOU", parents)
    santa_path = path_to("SAN", parents)
    return length(you_path) + length(santa_path) -
        2*n_shared_prefix(you_path, santa_path)
end

test_input_2 = """
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
    K)YOU
    I)SAN
    """

_, test_parents_2 = parse_input(test_input_2)

@test star2(test_parents_2) == 4

star2(parents)
