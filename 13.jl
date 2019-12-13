includet("./intcode.jl")
using .Intcodes

instructions = parse.(Int, split(chomp(read("13.input", String)), ','))

out = Channel{Int}(Inf)

c = Computer(instructions, output=out)
@async run!(c)
tiles = Iterators.partition(collect(out), 3)

sum(isequal(2) ∘ last, tiles)

