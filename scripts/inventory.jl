using EzXML
f = joinpath(pwd(), "src", "lex-wellformed.cex")
lines = readlines(f)

function inventorynames(lineslist)
    elementnames = []
    for ln in lineslist
        txt = string("<wrapper>", split(ln, "|")[3], "</wrapper>")
        doc = parsexml(txt)
    end
end


inventorynames(lines)