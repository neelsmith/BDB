#=
Utility to find records without clearly obvious lemma.
=#
using EzXML
f = joinpath(pwd(), "src", "lex-wellformed.cex")

# Skip header:
lines = readlines(f)[2:end]

hebrew_lemma = r"\|([IV., ]*)<bdbheb>([^<]+)</bdbheb>[, ]*"


function missinglemma(rawlines, lemma_re)
    nolemma = []
    for (i, ln) in enumerate(rawlines)        
        if occursin(lemma_re, ln)
        else
            #@warn("Failed to match on line $(i)")
            push!(nolemma, i)
        end
    end
    nolemma
end

missing = missinglemma(lines, hebrew_lemma)

@info("$(length(missing)) articles did not have a recognizable Hebrew lemma")

aramaic_lemma= r"\|([\[IV., ]*)<bdbarc>([^<]+)</bdbarc>[, ]*"
nolemma = []
for i in missing
    @info(string(i,". ", lines[i]))
    if occursin(aramaic_lemma, lines[i])
    else

        #@warn("Failed to match on line $(i)")
        push!(nolemma, i)
    end
end

nolemma |> println
@info("For $(length(nolemma)) entries, failed to recognize either lemma.")