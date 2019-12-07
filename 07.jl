using Test

includet("./intcode.jl")
using .Intcodes

# 5 intcode computers.  running the same program.  each one gets a different
# starting input ("phase") which is in 0:4.  Then output of previous computer
# gets fed into the next as the second input.  First input is 0.
#
# Could do this by running them serially for part 1 at least.
#
# But I have a hunch that for later problems the serial solution won't work, so
# might be worth using Channels to handle the input/output (like I was thinking
# about originally)



function star1_serial(instructions, phases)
    input = 0
    for p in phases
        c = Computer(instructions, input=[p, input])
        run!(c)
        input = last(outputs(c))
    end
    return input
end




@test star1_serial("3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0", [4,3,2,1,0]) == 43210

@test star1_serial("3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0",
                   0:4) == 54321

@test star1_serial("3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0", [1,0,4,3,2]) == 65210

function star1_channel(instructions, phases)
    input = Channel{Int}(Inf)
    output = input
    @sync begin 
        for p in phases
            c = Computer(instructions, input=output)
            put!(output, p)
            output = c.output
            @async run!(c)
        end
        put!(input, 0)
    end
    return take!(output)
end

@test star1_channel("3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0", [4,3,2,1,0]) == 43210

@test star1_channel("3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0", 0:4) == 54321

@test star1_channel("3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0", [1,0,4,3,2]) == 65210

input = read("07.input", String)
