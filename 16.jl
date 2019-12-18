
# "fft"
using Test
using Base.Iterators

fft(n) = drop(cycle(flatten((repeated(0, n),
                             repeated(1, n),
                             repeated(0, n),
                             repeated(-1, n)))), 1)

fft(n, x) = abs((take(fft(n), length(x)) ⋅ x) % 10)

parse_input(input) = parse.(Int, split(input, ""))

function star1(input, phases)
    cur = parse_input(input)
    work = copy(cur)

    for phase in 1:phases
        work .= (fft(n, cur) for n in 1:length(cur))
        cur, work = work, cur
    end

    return cur
end


@test star1("80871224585914546619083218645595", 100)[1:8] == parse_input("24176176") 
@test star1("19617804207202209144916044189917", 100)[1:8] == parse_input("73745418") 
@test star1("69317163492948606335995924319873", 100)[1:8] == parse_input("52432133")

input = chomp(read("16.input", String))

foreach(print, star1(input, 100)[1:8])
