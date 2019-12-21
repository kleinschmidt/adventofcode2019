includet("./intcode.jl")
using .Intcodes

instr = parse.(Int, split(chomp(read("19.input", String)), ','))

function drone(x,y)
    c = Computer(instr)
    @async run!(c)
    put!(c.input, x)
    put!(c.input, y)
    beam = take!(c.output)
end

function star1()
    beamed = 0
    for y in 0:49
        for x in 0:49
            beam = drone(x,y)
            print(beam == 1 ? '#' : '.')
            beamed += beam
        end
        println()
    end
    return beamed
end



# need to find the closest 100×100 square enclosed in the beam.  that's the same
# as finding the first bottom edge (x,y) where (x+99, y-99) is also in the beam
function star2()
    # start is a little tricky since the drone doesn't pick up the beam for a
    # few rows...
    y = 100
    x = 0
    while drone(x,y) == 0
        x += 1
    end

    while drone(x+99, y-99) == 0
        while drone(x,y) == 1
            y += 1
        end
        while drone(x,y) == 0
            x += 1
        end
        # @show x,y
    end

    return x*10_000 + y - 99
end
