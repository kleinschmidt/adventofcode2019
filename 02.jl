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

function star1(instr)
    t = Tape(instr)
    t.tape[1] = 12
    t.tape[2] = 2
    for _ in t
    end
    return t.tape[0]
end
