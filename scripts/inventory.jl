using EzXML
f = joinpath(pwd(), "src", "lex-wellformed.cex")
# Skip header:
lines = readlines(f)[2:end]

xml = map(lines) do ln
    "<x>" *  split(ln, "|")[3] * "</x>"
end

nd = xml[1] |> parsexml |> root



function inventorynames(n::EzXML.Node, namelist = String[])
    @info("Inventory node $(n.name) with list $(namelist) and type ELEMENT ==  $(n.type == 1)")
    newnames = namelist
    if n.type == EzXML.ELEMENT_NODE
        @info("IT's a node")
        if in(nd.name, namelist)
        else
            @info("New element name $(nd.name)")
            push!(newnames, nd.name)
            @info("Add name to list $(newnames)")
            
            children = elements(n)
      
            for c in children
                @info("recurse to child $(c.name)")
                newnames = inventorynames(c, newnames)
            end
        end
    end
    newnames
end

inventorynames(nd)








