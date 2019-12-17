parse_input(input) = Dict(parse_line.(split(chomp(input), '\n')))

function parse_line(input)
    left, right = split(strip(input), r" => ")
    left = parse_pair.(split(left, r", "))
    right = parse_pair(right)
    right.name => (yield=right.n, input=left)
end

parse_pair(s::AbstractString) = parse_pair(split(s, ' '))
parse_pair((n, name)) = (name=Symbol(name), n=parse(Int, n))

test_input =
    """
    10 ORE => 10 A
    1 ORE => 1 B
    7 A, 1 B => 1 C
    7 A, 1 C => 1 D
    7 A, 1 D => 1 E
    7 A, 1 E => 1 FUEL
"""

# reactions are the "incoming edges".  want to order the reagents starting with
# ORE and ending with FUEL so that if X occurs after Y in the list, we know that
# Y does not depend on X and we can figure out how many are required
#
# another way to think about it: before we can know how many times to run the A
# reaction, we need to produce, we need to know how much A we need, and so we
# need to know how much of everything that takes A as input...so A has to come
# AFTER all of the things that depend on it...so an "incoming edge" X→Y means Y
# depends on X.  ORE is the only thing with no incoming edge to start.  so put
# in ORE, then go over all the outgoing edges ORE→X 
function toposort(reactions)
    # outgoing[x] is everything that consumes x
    outgoing = Dict{Symbol,Set{Symbol}}()
    # incoming[x] is everthing that is required to produce x
    incoming = Dict{Symbol,Set{Symbol}}()
    for (output,v) in pairs(reactions)
        for input in v.input
            push!(get!(outgoing, input.name, Set(Symbol[])), output)
            push!(get!(incoming, output, Set(Symbol[])), input.name)
        end
    end

    roots = Set([:ORE])
    sorted = Symbol[]
    while !isempty(roots)
        node = pop!(roots)
        for x in get(outgoing, node, Symbol[])
            # remove node from incoming[x] (requirements to produce x)
            delete!(incoming[x], node)
            # if all requirements are satisfied
            if isempty(incoming[x])
                delete!(incoming, x)
                push!(roots, x)
            end
        end
        push!(sorted, node)
    end
    return sorted
end

star1(input::AbstractString, n=1) = star1(parse_input(input), n)
function star1(reactions::Dict, n=1)
    requirements = Dict(:FUEL => n)
    for output in reverse!(toposort(reactions))
        required = requirements[output]
        if haskey(reactions, output)
            times = ((required-1) ÷ reactions[output].yield) + 1
            for inp in reactions[output].input
                requirements[inp.name] = get(requirements, inp.name, 0) + times*inp.n
            end
        end
    end
    return requirements[:ORE]
end

star1(read("14.input", String))

# find the number in a range
function star2_search(range, reactions)
    length(range) ≤ 1 && return range.start - 1
    pivot = (range.start + range.stop) ÷ 2
    if star1(reactions, pivot) > 10^12
        return star2_search(range.start:pivot, reactions)
    else
        return star2_search((pivot+1):range.stop, reactions)
    end
end

# what can you produce with 1_000_000_000_000
function star2(input)
    reactions = parse_input(input)
    top = findfirst(n -> star1(reactions, 2^n) > 10^12, 1:40)
    range = 2^(top-1) : 2^top
    star2_search(range, reactions)
end


star2("""157 ORE => 5 NZVS
165 ORE => 6 DCFZ
44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL
12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ
179 ORE => 7 PSHF
177 ORE => 5 HKGWZ
7 DCFZ, 7 PSHF => 2 XJWVT
165 ORE => 2 GPVTF
3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT""") == 82892753

star2(read("14.input", String))
