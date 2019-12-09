# more intcodes!  two twists:
# memory is infinite
# "relative" parameter mode (2)
# opcode 9 updates relative base

using Test
includet("./intcode.jl")
using .Intcodes

function star1_test()
    inst = parse.(Int, split("109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99", ','))
    @test outputs(run!(Computer(inst))) == inst

    @test length(digits(outputs(run!(Computer("1102,34915192,34915192,7,4,7,99,0")))[1])) == 16

    inst = parse.(Int, split("104,1125899906842624,99", ','))
    @test outputs(run!(Computer(inst))) == inst[2:2]

end


input = parse.(Int, split(chomp(read("09.input", String)), ','))

function star1(input)
    c = Computer(input)
    @async(run!(c))
    put!(c.input, 1)
    [o for o in c.output]
end

out1 = star1(input)

function star2(input)
    c = Computer(input)
    @async(run!(c))
    put!(c.input, 2)
    [o for o in c.output]
end

@time out2 = star2(input)
