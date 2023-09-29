#=

=#
using EzXML
f = joinpath(pwd(), "src", "lexsrc-lemmatized.cex")

# Skip header:
for line in readlines(f)[2:end]
    cols = split(line, "|")
    
end

