using EzXML
f = "lex.cex"
lines = readlines(f)

failures = []
for (i, ln) in enumerate(lines[2:50])
    txt = string("<shell>", split(ln, "|")[3], "</shell>")
    @info(i +1)
    try
        doc = parsexml("<wrapper>" * txt * "</wrapper>")
        @info("Suceeded on line $(i + 1)")
    catch e
        push!(failures, i + 1)
        @warn("Failed at line $(i +1): ", txt)
    end
end

function reportall(lineslist)
    failureindices = []
    for (i, ln) in enumerate(lineslist)
        txt = string("<shell>", split(ln, "|")[3], "</shell>")
        try
            doc = parsexml("<wrapper>" * txt * "</wrapper>")
        catch e
            push!(failureindices, i + 1)
            @warn("Failed at line $(i +1)")
        end
    end
    failureindices
end

fails = reportall(lines[2:end])
fails[1]
function sample(n)
    sampleline = split(lines[n], "|")[3]
    sampleentry = string("<shell>", sampleline, "</shell>")
    try
        parsexml(sampleentry)
    catch e
        @warn("Failed to parse ", sampleentry)
        throw(e)
    end
end

sample(210)

lines[162]