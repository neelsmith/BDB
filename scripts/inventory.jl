#=
Find unique list of element names appearing in XML of the article column of the source document.
=#
using EzXML
f = joinpath(pwd(), "src", "lex-wellformed.cex")
# Skip header:
lines = readlines(f)[2:end]

xml = map(lines) do ln
    "<x>" *  split(ln, "|")[3] * "</x>"
end
parsed = map(xml) do x
    parsexml(x) |> root
end

function inventorynames(n::EzXML.Node, namelist = String[])
    newnames = namelist
    if n.type == EzXML.ELEMENT_NODE
        if in(n.name, namelist)
        else
            push!(newnames, n.name)
          
            children = elements(n)     
            for c in children
                newnames = inventorynames(c, newnames)
            end
        end
    end
    newnames
end


allelnames = map(nd -> inventorynames(nd), parsed)

elnames = vcat(allelnames...) |> unique

join(elnames,"\n") |> println
