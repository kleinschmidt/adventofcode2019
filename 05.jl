includet("intcode.jl")

using .Intcodes

instructions = parse.(Int, split(chomp(read("05.input", String)), ','))

c = Computer(instructions, input=[1])

collect(c)
