
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

# this is an O(N²) which is too slow for big inputs :( need to do some kind of
# FFT-like divide and conquor algorithm...it's a divide and conquour kind of
# thing right?  If you have N = N₁N₂ then you do N₁ and N₂ separate DFTs and
# combine them somehow... how does that work in this case?  the classic FFT
# algorithm is Cooley-Tukey, which splits the data into even- and odd-index
# sets, recursively, computes teh DFT of each subset and combines them by
# adding/subtracting (weighting the odd-index DFT by ...something having to do
# with the period)


# let's consider k=1, which is
#
# 1  2  3  4  5  6  7  8 ...
# 1  0 -1  0  1  0 -1  0
#
# in this case, the evens have weight 0 and odds have weight 1 (well that's
# using the 1-indexed form, whereas the wikipedia algorithm is 0-indexed).
#
# 1     3     5     7
# O     E     O     E
#
# so it's sum(O) - sum(E)


# what about k=2
#
# 1  2  3  4  5  6  7  8 ...
# 0  1  1  0  0 -1 -1  0 ...
# O  E  O  E  O  E  O  E
#
# so then we have
#
# 1  3  5  7  9 11 13
# 0  1  0 -1  0  1  0
#
# and
#
# 2  4  6  8 10 12 14
# 1  0 -1  0  1  0 -1

# and k=3
# 
# 1  2  3  4  5  6  7  8  9 10 11 12 13 14
# 0  0  1  1  1  0  0  0 -1 -1 -1  0  0  0
#
# 1  3  5  7  9 11 13 15 17 19 21 23
# 0  1  1  0 -1 -1  0  1  1  0 -1 -1
#
# 1  5  9 13 17 21
# 0  1 -1  0  1 -1 ...
#
# 3  7 11 15 19 23
# 1  0 -1  1  0 -1 ... (phase shifted)
#
# 1  9 17 25
# 0 -1  1  0 ...
# 
#
# 2  4  6  8 10 12 14 16 18 20 22
# 0  1  0  0 -1  0  0  1  0  0 -1
#
# 2  6 10 14 18 22
# 0  0 -1  0  0 -1
#
# 4  8 12 16 20 24
# 1  0  0  1  0  0 ... (phase shifted * -1)
