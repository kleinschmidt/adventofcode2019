# N-body simulation.  four moons...first update velocity for every pair.  then
# update position.
using Test
using StaticArrays

const Vec3 = MVector{3,Int}

struct Moon
    pos::Vec3
    vel::Vec3
end

Moon(x,y,z) = Moon(Vec3([x,y,z]), Vec3([0,0,0]))

gravity!((a,b)) = gravity!(a,b)
function gravity!(a::Moon, b::Moon)
    Δv = sign.(a.pos .- b.pos)
    a.vel .-= Δv
    b.vel .+= Δv
end

function parse_line(input)
    m = match(r"<x=(-?[0-9]+), y=(-?[0-9]+), z=(-?[0-9]+)>", input)
    Moon(parse.(Int, m.captures)...)
end

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

energy(moons::Vector{Moon}) = sum(energy, moons)
energy(moon::Moon) = sum(abs.(moon.pos)) * sum(abs.(moon.vel))


function star1(input, n)
    moons = parse_line.(split(chomp(input), '\n'))
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


