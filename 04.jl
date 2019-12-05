using Test

input = parse.(Int, split("245182-790572", '-'))

star1_pred = let digs = digits(input[2])
    function star1_pred(n)
        digits!(digs, n)
        has_repeat = false
        no_decrease = true
        for i in 1:length(digs)-1
            has_repeat |= digs[i] == digs[i+1]
            no_decrease &= digs[i] >= digs[i+1]
        end
        has_repeat && no_decrease
    end
end

function star1(input)
    passwords = Int[]
    for n in input[1]:input[2]
        if star1_pred(n)
            push!(passwords, n)
        end
    end
    length(passwords)
end

star1(input)

star2_pred = let digs=digits(input[2])
    function(n)
        digits!(digs, n)
        has_repeat = false
        run_len = 1
        run_n = first(digs)
        no_decrease = true
        for i in 2:length(digs)
            digs[i-1], digs[i]
            if !has_repeat
                if digs[i] == run_n
                    run_len += 1
                    run_n, run_len
                else
                    # end of a run...check if it's exactly 2
                    has_repeat = run_len == 2
                    run_len = 1
                    run_n = digs[i]
                end
            end
            no_decrease &= digs[i-1] >= digs[i]
        end
        has_repeat |= run_len == 2 # handle repeat in final two
        has_repeat && no_decrease
    end
end

@test star2_pred(112233)
@test !star2_pred(123444)
@test star2_pred(111122)
@test star2_pred(112222)

function star2(input)
    start, finish = input
    passwords = Int[]
    for n in start:finish
        if star2_pred(n)
            push!(passwords, n)
        end
    end
    return length(passwords)
end

star2(input)
