# "hull painting robot"
#
# brain is IntCode computer.  takes color of panel as input, outputs (color,
# turn) pair.  0 black, 1 white.  0 left, 1 right.
#
# moves forward one step ever time

includet("./intcode.jl")
using .Intcodes
using StaticArrays
using OffsetArrays

instr = parse.(Int, split(chomp(read("11.input", String)), ','))

const left = @SArray [0  1
                      -1 0]
const right = -left
turn!(vec, turn_dir) = vec .= (turn_dir == 0 ? left : right) * vec

function paint(instr, panels=fill!(OffsetArray{Bool}(undef, -100:100, -100:100), false))

    out = Channel{Int}(0)
    inp = Channel{Int}(Inf)

    brain = Computer(instr, input=inp, output=out)

    visited = copy(panels)

    location = [0,0]
    direction = [0,-1]

    @async run!(brain)

    while true
        try
            put!(inp, panels[location...])
            panels[location...] = take!(out)
            turn!(direction, take!(out))
            visited[location...] = true
            location .+= direction
        catch e
            if e isa InvalidStateException && e.state === :closed
                return panels, visited
            else
                rethrow(e)
            end
        end
    end

    return panels, visited

end

star1(input) = sum(last(paint(input)))

function star2(input)
    panels = fill!(OffsetArray{Bool}(undef, -100:100, -100:100), false)
    panels[0,0] = true
    panels, visited = paint(input, panels)

    # too lazy to find the bounding box automatically...(0,0):(40,5) should do
    # it looks like
    foreach(row -> println(join(replace(row, false=>' ', true=>'#'))), eachslice(panels[0:40, 0:5], dims=2))

end
