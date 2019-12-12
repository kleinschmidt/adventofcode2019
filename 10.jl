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

polar_coord(x) = [-atan(x...), norm(x)]

# star 2: sort other asteroids by angle and then by distance (rotating laser!)
function star2(input)
    _, base_coord = star1(input)
    
    coords_raw = map(x->x.-1, filter(!isequal(base_coord.+1), asteroid_coords(input)))
    coords_polar = map(c -> polar_coord(c .- base_coord), coords_raw)
    
    polar_raw = sort!(collect(zip(coords_polar, coords_raw)))
    last_θ = 0.
    run_n = 1
    for (polar, raw) in polar_raw
        if polar[1] == last_θ
            polar[1] += 2π * run_n
            run_n += 1
        else
            run_n = 1
            last_θ = polar[1]
        end
    end

    sort!(polar_raw)
    return last.(polar_raw)

end


star2("""
.#....#####...#..
##...##.#####..##
##...#...#.#####.
..#.....#...###..
..#.#.....#....##
""")


star2(test_input_big)[[1, 2, 3, 10, 20, 50, 100, 199, 200, 201, 299]]

star2(read("10.input", String))
