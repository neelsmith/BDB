using Downloads, JSON3


function parse_url(u)
    f = Downloads.download(u)

    parsed = JSON3.read(f)
    rm(f)
    parsed
end
