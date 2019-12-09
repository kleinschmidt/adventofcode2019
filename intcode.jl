module Intcodes

import Base: iterate
using OffsetArrays

export
    Computer,
    Op,
    compute,
    outputs,
    run!

# helpers
channel(c::Channel) = c
function channel(x)
    c = Channel{eltype(x)}(Inf)
    foreach(xx -> put!(c, xx), x)
    return c
end


# format is
# opcode, addr1, addr2, addr3
#
# opcode 1 is addition, 2 is multiplcation, 99 is terminate
# reads from addr1, addr2 and writes to addr3 (zero-indexed)
#
# then advance four positions to next opcode.

struct Op{T,N}
    code::Int
    name::T
    nargs::Int
    modes::NTuple{N,Int}
end

ops = Dict(
    1 => (+, 3),
    2 => (*, 3),
    3 => (:input, 1),
    4 => (:output, 1),
    5 => (:jumpiftrue, 2),
    6 => (:jumpiffalse, 2),
    7 => (<, 3),
    8 => (==, 3),
    9 => (:adjustrelativebase, 1),
    99 => (:terminate, 0)
)

function Op(inst::Int)
    code = rem(inst, 100)
    inst = inst ÷ 100
    name, nargs = ops[code]
    modes = ntuple(i -> rem(inst ÷ 10^(i-1), 10), nargs)
    Op(code, name, nargs, modes)
end

struct Arg
    addr::Int
    mode::Int
end

struct Computer{T}
    tape::T
    input::Channel{Int}
    output::Channel{Int}
    id::Union{Int,Nothing}
    relative_base::Int

    Computer(tape::T, input, output, id) where {T} = new{T}(tape, input, output, id, 0)
end

Computer(instructions::Array; input=Int[], output=Channel{Int}(Inf), id=nothing) =
    Computer(OffsetArray(copy(instructions), 0:length(instructions)-1),
             channel(input),
             output,
             id)
Computer(instructions::String; input=Int[], output=Channel{Int}(Inf), id=nothing) =
    Computer(parse.(Int, split(instructions, ',')),
             input=input, output=output, id=id)

# general strategy so far has been to treat the computer as an iterator that
# returns...what?  the tape itself?  and the pointer for the next instruction.
# can use the iterated values as the output I guess.

get(c::Computer, arg::Int, absmode::Int) = absmode==1 ? arg : c.tape[arg]

Base.IteratorSize(::Type{<:Computer}) = Base.SizeUnknown()

iterate(c::Computer) = iterate(c, 0)
function iterate(c::Computer, state)
    op = Op(c.tape[state])
    args = @view c.tape[state .+ (1:op.nargs)]
    # args = get.(Ref(c), state .+ (1:n_args[op.code]), op.modes[1:n_args[op.code]])

    next_state = state + 1 + op.nargs
    retval = nothing

    println("[$(c.id)]: @$state $(c.tape[state]) $(op.name) $(op.modes) ($(args...))")

    if op.name isa Function
        retval = c.tape[args[3]] = op.name(get(c, args[1], op.modes[1]),
                                           get(c, args[2], op.modes[2]))
    elseif op.name === :input
        retval = c.tape[args[1]] = take!(c.input)
    elseif op.name === :output
        retval = put!(c.output, get(c, args[1], op.modes[1]))
    elseif op.name === :jumpiftrue
        if get(c, args[1], op.modes[1]) != 0
            next_state = get(c, args[2], op.modes[2])
        end
    elseif op.name === :jumpiffalse
        if get(c, args[1], op.modes[1]) == 0
            next_state = get(c, args[2], op.modes[2])
        end
    elseif op.name === :terminate
        close(c.output)
        close(c.input)
        return nothing
    else
        error("Invalid op: $(op)")
    end
    
    println("[$(c.id)]: $(op.name), $retval, $next_state")
    return (op.name, retval), next_state
end

function run!(c::Computer)
    for _ in c
    end
    c
end


compute(instructions, input) = collect(Computer(instructions, input=input))
outputs(instructions, input) = outputs(run!(Computer(instructions, input=input)))
outputs(c::Computer) = [n for n in c.output]

end
