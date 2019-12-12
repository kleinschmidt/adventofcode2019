using Test

function asteroid_coords(input)
    chars = reduce(hcat, split.(split(chomp(input), '\n'), ""))
    Tuple.(CartesianIndices(chars)[chars .== "#"])
end

function star1(input)
    coords = asteroid_coords(input)
    angles = [a==b ? NaN : atan((a.-b)...) for a in coords, b in coords]
    n, i = findmax(map(length ∘ unique, eachslice(angles, dims=2)))
    (n-1, coords[i] .- 1)
end



@test star1("""
......#.#.
#..#.#....
..#######.
.#.#.###..
.#..#.....
..#....#.#
#..#....#.
.##.#..###
##...#..#.
.#....####
""") == (33, (5,8))

@test star1("""
#.#...#.#.
.###....#.
.#....#...
##.#.#.#.#
....#.#.#.
.##..###.#
..#...##..
..##....##
......#...
.####.###.
""") == (35, (1,2))

@test star1("""
.#..#..###
####.###.#
....###.#.
..###.##.#
##.##.#.#.
....###..#
..#.#..#.#
#..#.#.###
.##...##.#
.....#.#..
""") == (41, (6,3))

test_input_big = """
.#..##.###...#######
##.############..##.
.#.######.########.#
.###.#######.####.#.
#####.##.#.##.###.##
..#####..#.#########
####################
#.####....###.#.#.##
##.#################
#####.##.###..####..
..######..##.#######
####.##.####...##..#
.#####..#.######.###
##...#.##########...
#.##########.#######
.####.#.###.###.#.##
....##.##.###..#####
.#.#.###########.###
#.#.#.#####.####.###
###.##.####.##.#..##
"""
@test star1(test_input_big) == (210, (11,13))

n, (x,y) = star1(read("10.input", String))
