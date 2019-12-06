using Base: Fix1, Fix2
using Test

input = read("02.input", String) |> strip |> Fix2(split, ",") .|> Fix1(parse, Int)
# input = parse.(Int, split(strip(read("02.input", String)), ","))

includet("intcode.jl")
using .Intcodes

function run_tape(instr, noun, verb)
    t = Computer(instr)
    t.tape[1] = noun
    t.tape[2] = verb
    for _ in t
    end
    return t.tape[0]
end

star1(instr) = run_tape(instr, 12, 2)

star1(input)

# just brute force search all nouns and verbs from 0 to 99
function star2(input, output)
    for noun in 0:99
        for verb in 0:99
            run_tape(input, noun, verb) == output && return 100*noun + verb
        end
    end
    error("Didn't find a solution")
end

@test star2(input, 3516593) == 1202

star2(input, 19690720)
