#=
Utility script to identify XML fragments that are not well formed.

Now that the source document has been reduced to a series of well-formed XML fragments, this script is no longer need.
=#
using EzXML
f = "lex.cex"

function reportall(lineslist)
    failureindices = []
    for (i, ln) in enumerate(lineslist)
        txt = string("<shell>", split(ln, "|")[3], "</shell>")
        try
            doc = parsexml(txt)
        catch e
            push!(failureindices, i + 1)
            @warn("Failed at line $(i +1)")
        end
    end
    failureindices
end



lines = readlines(f)
fails = reportall(lines[2:end])
fails[1]


function sample(n)
    @info("Sampling line $(n)...")
    sampleline = split(lines[n], "|")[3]
    sampleentry = string("<shell>", sampleline, "</shell>")
    try
        parsexml(sampleentry)
    catch e
        @warn("Failed to parse ", sampleentry)
        throw(e)
    end
end

sample(558)

