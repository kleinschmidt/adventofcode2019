using Base: Fix1, Fix2
using OffsetArrays


input = read("02.input", String) |> strip |> Fix2(split, ",") .|> Fix1(parse, Int)
# input = parse.(Int, split(strip(read("02.input", String)), ","))

# format is
# opcode, addr1, addr2, addr3
#
# opcode 1 is addition, 2 is multiplcation, 99 is terminate
# reads from addr1, addr2 and writes to addr3 (zero-indexed)
#
# then advance four positions to next opcode.

struct Tape{A}
    tape::A
end

Tape(instructions::Array) = Tape(OffsetArray(copy(instructions), 0:length(instructions)-1))

import Base: iterate

const ops = [+, *]

iterate(t::Tape) = t, 0
function iterate(t::Tape, state)
    t.tape[state] == 99 && return nothing
    t.tape[state] ∈ (1,2) || error("Invalid op: $(t.tape[state])")
    op, a1, a2, a3 = t.tape[state:state+3]
    t.tape[a3] = ops[op](t.tape[a1], t.tape[a2])
    return t, state+4
end

function run_tape(instr, noun, verb)
    t = Tape(instr)p
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

star2(input, 3516593) == 1202

star2(input, 19690720)
