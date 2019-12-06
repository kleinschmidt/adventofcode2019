module Intcodes

import Base: iterate
using OffsetArrays

export
    Computer,
    Op

# format is
# opcode, addr1, addr2, addr3
#
# opcode 1 is addition, 2 is multiplcation, 99 is terminate
# reads from addr1, addr2 and writes to addr3 (zero-indexed)
#
# then advance four positions to next opcode.

struct Op
    code::Int
    modes::Tuple{Bool,Bool,Bool}
end    

function Op(inst::Int)
    code = rem(inst, 100)
    inst = inst ÷ 100
    modes = ntuple(i -> rem(inst ÷ 10^(i-1), 10), 3)
    Op(code, modes)
end

struct Computer{T}
    tape::T
    input::Array{Int}
end

Computer(instructions::Array; input=Int[]) =
    Computer(OffsetArray(copy(instructions), 0:length(instructions)-1),
             input)
Computer(instructions::String; input=Int[]) =
    Computer(parse.(Int, split(instructions, ',')), input=input)

const ops = Dict(
    1 => +,
    2 => *,
    3 => :input,
    4 => :output,
    99 => :terminate
)

const n_args = Dict(
    1 => 3,
    2 => 3,
    3 => 1,
    4 => 1,
    99 => 0
)

# general strategy so far has been to treat the computer as an iterator that
# returns...what?  the tape itself?  and the pointer for the next instruction.
# can use the iterated values as the output I guess.

get(c::Computer, arg::Int, absmode::Bool) = absmode ? arg : c.tape[arg]

iterate(c::Computer) = iterate(c, 0)
function iterate(c::Computer, state)
    op = Op(c.tape[state])
    args = @view c.tape[state .+ (1:n_args[op.code])]
    # args = get.(Ref(c), state .+ (1:n_args[op.code]), op.modes[1:n_args[op.code]])

    op_name = ops[op.code]

    if op_name isa Function
        retval = c.tape[args[3]] = op_name(get(c, args[1], op.modes[1]),
                                           get(c, args[2], op.modes[2]))
    elseif op_name === :input
        retval = c.tape[args[3]] = pop!(c.input)
    elseif op_name === :output
        retval = get(c, args[1], op.modes[1])
    elseif op_name === :terminate
        return nothing
    else
        error("Invalid op: $(op)")
    end

    return (op_name, retval), state + 1 + n_args[op.code]
end


end
