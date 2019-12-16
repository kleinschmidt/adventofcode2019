using REPL: Terminals
using OffsetArrays
includet("./intcode.jl")
using .Intcodes


tiles = OffsetArray([' ', '#', '=', '—', '◯'], 0:4)
instructions = parse.(Int, split(chomp(read("13.input", String)), ','))

function star1() 
    out = Channel{Int}(Inf)
    c = Computer(instructions, output=out)
    @async run!(c)
    tiles_out = Iterators.partition(collect(out), 3)
    sum(isequal(2) ∘ last, tiles_out)
end

mutable struct Game
    screen::Dict{Tuple{Int,Int},Char}
    score::Int
    paddle::Tuple{Int,Int}
    ball::Tuple{Int,Int}
    input::Channel{Int}
    output::Channel{Int}
end

function Game(instructions, quarters=2)
    inp = Channel{Int}(0)
    out = Channel{Int}(Inf)

    game = Game(Dict{Tuple{Int,Int},Char}(), 0, (0,0), (0,0), inp, out)

    instructions = copy(instructions)
    instructions[1] = quarters

    c = Computer(instructions, input=inp, output=out)
    @async run!(c)
    @async for xyt in Iterators.partition(out, 3)
        update!(game, xyt)
    end

    return game
end

function update!(game::Game, (x,y,t))
    if (x,y) == (-1,0)
        game.score = t
        return game
    end
    
    game.screen[(x,y)] = tiles[t]
    if tiles[t] == '◯'
        game.ball = (x,y)
    elseif tiles[t] == '—'
        game.paddle = (x,y)
    end
    return game
end

clear_term() = print("$(Terminals.CSI)H"); print("$(Terminals.CSI)?25l")

function disp(game)
    (xmin, ymin), (xmax, ymax) = extrema(keys(game.screen))

    clear_term()
    for row in ymin:ymax
        for col in xmin:xmax
            print(game.screen[(col, row)])
        end
        println()
    end
    println("Score: $(game.score)")
end


function solve(instructions; show=true)
    g = Game(instructions, 2)
    while isopen(g.input)
        put!(g.input, sign(g.ball[1]-g.paddle[1]))
        if show
            disp(g)
        end
    end
    return g.score
end
