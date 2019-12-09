function countmap(xs)
    counts = Dict{eltype(xs), Int}()
    for x in xs
        counts[x] = get(counts, x, 0) + 1
    end
    return counts
end

imgs = reshape([parse(Int, c) for c in chomp(read("08.input", String))],
               25, 6, :)

prod(minimum(x->getindex.(Ref(countmap(x)), (0,1,2)), eachslice(imgs, dims=3))[2:3])



foreach(row -> println(join(ifelse.(row.==0, ' ', '#'))),
        eachslice(foldl((top,bot) -> ifelse.(top.==2, bot, top),
                        eachslice(imgs, dims=3)),
                  dims = 2))
                
