using Test

using Pkg
Pkg.activate(@__DIR__)

parse_inst(s) = s[1], parse(Int, s[2:end])
parse_inst(ss::Array{<:AbstractString}) = parse_inst.(ss)

input = parse_inst.(split.(readlines("03.input"), ','))

# turn into vectors
using StaticArrays
const Vec2 = SArray{Tuple{2}}

const directions = Dict('R' => Vec2([1, 0]),
                        'L' => Vec2([-1, 0]),
                        'U' => Vec2([0,1]),
                        'D' => Vec2([0,-1]))
vectorify(dir::Char, steps::Int) = steps .* directions[dir]
vectorify(x::Tuple{Char, Int}) = vectorify(x...)

vecs = [vectorify.(inp) for inp in input]
vertices = [pushfirst!(cumsum(v), Vec2([0,0])) for v in vecs]


# two wires a₁a₂ and b₁b₂ intersect when:
# sign(a₁b₂⋅b₁b₂) * sign(a₁b₁⋅b₁b₂) = -1
# sign(a₁b₂⋅a₁a₂) * sign(a₂b₂⋅a₁a₂) = -1
using LinearAlgebra
function intersect(a, b)
    sign.(a[1] - a[2]) == sign.(b[1] - b[2]) && return nothing

    axb = a[1][1] == a[2][1] ? # a's x coords are equal
        Vec2([a[1][1], b[1][2]]) :
        Vec2([b[1][1], a[1][2]])

    (a[1] - axb) ⋅ (a[2] - axb) <= 0 || return nothing
    (b[1] - axb) ⋅ (b[2] - axb) <= 0 || return nothing
    return axb
end


@test intersect(([-1, 0], [1, 0]), ([0, -1], [0, 1])) == [0,0]
@test intersect(([0, -1], [0, 1]), ([-1, 0], [1, 0])) == [0,0]
@test intersect(([-1, 0], [1, 0]), ([-1, 0], [1, 0])) == nothing
@test intersect(([-1, 0], [1, 0]) .+ Ref([0,5]), ([0, -1], [0, 1])) == nothing
@test intersect(([-1, 0], [1, 0]), ([0, -1], [0, 1]) .+ Ref([0,5])) == nothing
@test intersect(([-1, 0], [1, 0]), ([0, -1], [0, 1]) .+ Ref([5,0])) == nothing
@test intersect(([-1, 0], [1, 0]), ([0, -1], [0, 1]) .+ Ref([1,0])) == [1, 0]


edges = [zip(v[1:end-1], v[2:end]) for v in vertices]

intersections = Iterators.drop(Iterators.filter(!isnothing, intersect(a, b) for a in edges[1] for b in edges[2]), 1)

sort(collect(intersections), by=x->sum(abs.(x)))
minimum(x->sum(abs.(x)), intersections)


steps(vecs) = cumsum([sum(abs.(v))-1 for v in vecs])
vec_steps = steps.(vecs)

inters_enum =
    Iterators.drop(
        ((ai, bi) for (ai, a) in enumerate(edges[1]) for (bi, b) in enumerate(edges[2]) if !isnothing(intersect(a,b))),
        1)
