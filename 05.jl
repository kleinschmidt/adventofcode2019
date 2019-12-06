using Test

includet("intcode.jl")

using .Intcodes

instructions = parse.(Int, split(chomp(read("05.input", String)), ','))

star1(instructions) = last(outputs(instructions, [1]))

@test star1(instructions) == 12440243

# star 2 test cases
@test [first(outputs("3,9,8,9,10,9,4,9,99,-1,8", [n])) for n in 1:10] == (1:10 .== 8)
@test [first(outputs("3,9,7,9,10,9,4,9,99,-1,8", [n])) for n in 1:10] == (1:10 .< 8)
@test [first(outputs("3,3,1108,-1,8,3,4,3,99", [n])) for n in 1:10] == (1:10 .== 8)
@test [first(outputs("3,3,1107,-1,8,3,4,3,99", [n])) for n in 1:10] == (1:10 .< 8)

@test [first(outputs("3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9", [n])) for n in -3:3] ==
    (-3:3 .!= 0)
@test [first(outputs("3,3,1105,-1,9,1101,0,0,12,4,12,99,1", [n])) for n in -3:3] ==
    (-3:3 .!= 0)

in_test = "3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99"
out_test(n) = n < 8 ? 999 :
    n == 8 ? 1000 :
    1001

@test [first(outputs(in_test, [n])) for n in 1:10] == out_test.(1:10)


outputs(instructions, [5])
