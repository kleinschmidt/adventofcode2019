using Pkg
Pkg.activate(@__DIR__)

input = parse.(Int, readlines("01.input"))

test_input = [12, 14, 1969, 100756]

f = x -> x ÷ 3 - 2

map(f, test_input)
mapreduce(f, +, input, init=0)

function g(x)
    total = 0
    fuel = f(x)
    while fuel > 0
        total += fuel
        x, fuel = fuel, f(fuel)
    end
    return total
end

g.(test_input)
mapreduce(g, +, input, init=0)
