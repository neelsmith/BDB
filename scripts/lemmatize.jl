#=
Add lemmata and note on language to source data.
=#
using EzXML
f = joinpath(pwd(), "src", "lex-wellformed.cex")

# Skip header:
lines = readlines(f)[2:end]



hebrew_lemma = r"\|([IV., ]*)<bdbheb>([^<]+)</bdbheb>[, ]*"
aramaic_lemma= r"\|([\[IV., ]*)<bdbarc>([^<]+)</bdbarc>[, ]*"

rewrites = ["BDBid|StrongNumber|Language|Lemma|Entry"]
failures = []
for (i,l) in enumerate(lines)
    if occursin(hebrew_lemma, l)
        push!(rewrites, replace(l, hebrew_lemma => s"|Hebrew|\2|"))
    elseif occursin(aramaic_lemma, l)
        push!(rewrites,        replace(l, aramaic_lemma => s"|Aramaic|\2|"))
    else
        push!(failures, i)
    end
end

outfile = joinpath(pwd(), "src", "lexsrc-lemmatized.cex")
open(outfile, "w") do io
    write(io, join(rewrites, "\n"))
end