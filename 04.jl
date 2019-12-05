input = "245182-790572"

function star1(input)
    start, finish = parse.(Int, split(input, '-'))
    digs = digits(finish)
    passwords = Int[]
    for n in start:finish
        digits!(digs, n)
        has_repeat = false
        no_decrease = true
        for i in 1:length(digs)-1
            has_repeat |= digs[i] == digs[i+1]
            no_decrease &= digs[i] >= digs[i+1]
        end
        has_repeat && no_decrease && push!(passwords, n)
    end
    return length(passwords)
end


function star2(input)
    start, finish = parse.(Int, split(input, '-'))
    digs = digits(finish)
    passwords = Int[]
    for n in start:finish
        digits!(digs, n)
        has_repeat = false
        repeated = -1
        n_repeat = 0
        no_decrease = true
        for i in 1:length(digs)-1
            if !has_repeat && digs[i] == digs[i+1]
                n_repeat += digs[i] == repeated
                repeated = digs[i]
            else
                # end of a run...check if it's exactly 2
                has_repeat = n_repeat == 2
            end
            no_decrease &= digs[i] >= digs[i+1]
        end
        has_repeat && no_decrease && push!(passwords, n)
    end
    return length(passwords)
end
