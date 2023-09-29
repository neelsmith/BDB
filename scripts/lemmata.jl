#=
Utility to find records without clearly obvious lemma.
=#
using EzXML
f = joinpath(pwd(), "src", "lex-wellformed.cex")

# Skip header:
lines = readlines(f)[2:end]

lemma_re = r"\|<bdbheb>([^<]+)</bdbheb>[, ]*"


function missinglemma(rawlines)
    nolemma = []
    for (i, ln) in enumerate(rawlines)
        lineno = i + 1
        
        if occursin(lemma_re, ln)
        else
            @warn("Failed to match on line $(lineno)")
            push!(nolemma, lineno)
        end
    end
    nolemma
end

missing = missinglemma(lines)
