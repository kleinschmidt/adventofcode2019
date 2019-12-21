includet("./intcode.jl")
using .Intcodes


function star1()
    instr = parse.(Int, split(chomp(read("19.input", String)), ','))
    beamed = 0
    for y in 1:50
        for x in 1:50
            c = Computer(instr)
            @async run!(c)
            put!.(Ref(c.input), (x,y).-1)
            beam = take!(c.output)
            print(beam == 1 ? '#' : '.')
            beamed += beam
        end
        println()
    end
    return beamed
end



