using Test
using Combinatorics

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


function star1_channel(instructions, phases)
    computers = [Computer(instructions, input=[p]) for p in phases]
    for ci in 2:length(computers)
        println("connecting $(ci-1)→$(ci)")
        @async begin
            x = take!(computers[ci-1].output)
            println("$(ci-1)→$(ci): $x")
            put!(computers[ci].input, x)
        end
    end
    put!(computers[1].input, 0)
    @async foreach(run!, computers)
    return take!(computers[end].output)
end


function star1_tests()

    @test star1_serial("3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0", [4,3,2,1,0]) == 43210

    @test star1_serial("3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0",
                       0:4) == 54321

    @test star1_serial("3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0", [1,0,4,3,2]) == 65210

    @test star1_channel("3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0", [4,3,2,1,0]) == 43210

    @test star1_channel("3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0", 0:4) == 54321

    @test star1_channel("3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0", [1,0,4,3,2]) == 65210
end

function star1()
    input = read("07.input", String)
    input_ints = parse.(Int, split(chomp(input), ','))
    maximum(star1_channel(input_ints, phases) for phases in permutations(0:4))
end

# hook up the output of the last computer to the input of the first...
function star2_channel(instructions, phases)
    final_output = Channel{Int}()
    computers = [Computer(instructions, input=[p], id=i) for (i,p) in enumerate(phases)]
    for ci in 1:length(computers)
        ci_prev = ci == 1 ? length(computers) : ci-1
        println("connecting $(ci_prev)→$(ci)")
        @async begin
            while isopen(computers[ci_prev].output)
                x = take!(computers[ci_prev].output)
                if isopen(computers[ci].input)
                    println("$(ci_prev)→$(ci): $x")
                    put!(computers[ci].input, x)
                else
                    put!(final_output, x)
                end
            end
        end
    end
    put!(computers[1].input, 0)
    @sync for c in computers
        @async run!(c)
    end
    # final output gets sent as input to computer 1...
    return take!(final_output)
end



function star2_tests()
    instructions = "3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5"
    phases = [9,8,7,6,5]
    @test star2_channel(instructions, phases) == 139629729

    @test star2_channel("3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54," *
                        "-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4," *
                        "53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10",
                        [9,7,8,5,6]) == 18216
end

function star2()
    input = read("07.input", String)
    input_ints = parse.(Int, split(chomp(input), ','))
    maximum(star2_channel(input_ints, phases) for phases in permutations(5:9))
end
