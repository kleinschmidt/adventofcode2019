# N-body simulation.  four moons...first update velocity for every pair.  then
# update position.
using Test
using StaticArrays

struct Moon{N}
    pos::MVector{N,Int}
    vel::MVector{N,Int}
end

Moon(x::Vararg{Int,N}) where N = Moon(MVector{N,Int}([x...]), MVector{N,Int}(zeros(Int,N)))

gravity!((a,b)) = gravity!(a,b)
function gravity!(a::Moon, b::Moon)
    Δv = sign.(a.pos .- b.pos)
    a.vel .-= Δv
    b.vel .+= Δv
end

line_to_coords(input) =
    parse.(Int, match(r"<x=(-?[0-9]+), y=(-?[0-9]+), z=(-?[0-9]+)>", input).captures)

function simulate!(moons)
    for i in 1:length(moons)
        for j in i+1:length(moons)
            gravity!(moons[i], moons[j])
        end
    end
    for moon in moons
        moon.pos .+= moon.vel
    end
    return moons
end

energy(moons::Vector{Moon{N}}) where N = sum(energy, moons)
energy(moon::Moon) = sum(abs.(moon.pos)) * sum(abs.(moon.vel))


function star1(input, n)
    coords = line_to_coords.(split(chomp(input), '\n'))
    moons = [Moon(x...) for x in coords]
    foreach((i) -> simulate!(moons), 1:n)
    energy(moons)
end


@test star1("""
<x=-1, y=0, z=2>
<x=2, y=-10, z=-7>
<x=4, y=-8, z=8>
<x=3, y=5, z=-1>
""", 10) == 179

@test star1("""
<x=-8, y=-10, z=0>
<x=5, y=5, z=10>
<x=2, y=-7, z=3>
<x=9, y=-8, z=-3>
""", 100) == 1940

star1(read("12.input", String), 1000)


# dynamics are entirely determined by the sign of the differences.  so just need
# to find the points when the signs of the differences will flip...and run
# between those?

# another thing...it seems like maybe you could calculate the periods relative
# to individual dimensions...like the gravity effects don't ever bleed over from
# one dimension to the other.  so you could find the period of the individual
# dimensions and then the LCM of those...
#
# and maybe there's some additional efficiency from lack of interactions between
# moons but... probably not

Base.:(==)(a::Moon, b::Moon) = a.pos == b.pos && a.vel == b.vel

moon_tuple(moon::Moon{N}) where {N} = (moon.pos..., moon.vel...)

function moon_period(moons)
    moon_tup = moon_tuple.(moons)
    moonset = Set{typeof(moon_tup)}()
    period = 0
    while moon_tup ∉ moonset
        period += 1
        push!(moonset, moon_tup)
        simulate!(moons)
        moon_tup = moon_tuple.(moons)
    end
    return period
end    

function star2(input)
    coords = line_to_coords.(split(chomp(input), '\n'))
    moons_moons = [Moon.(x) for x in collect(zip(coords...))]
    lcm(moon_period.(moons_moons))
end

@test star2("""
<x=-1, y=0, z=2>
<x=2, y=-10, z=-7>
<x=4, y=-8, z=8>
<x=3, y=5, z=-1>
""") == 2772

@test star2("""
<x=-8, y=-10, z=0>
<x=5, y=5, z=10>
<x=2, y=-7, z=3>
<x=9, y=-8, z=-3>
""") == 4686774924

star2(read("12.input", String))
