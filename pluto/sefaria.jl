### A Pluto.jl notebook ###
# v0.19.46

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 12c54c07-f2ef-427c-90ab-c1662fc07a25
begin
	using PlutoUI
	using Downloads
	using HTTP
	using JSON3
	md"""*Unhide this cell to see the Julia environment*."""
end

# ╔═╡ 7782fefc-7774-11ef-25bf-1714acd3d1c1
md"""# Simple examples using Sefaria APIs"""

# ╔═╡ 52088b63-d040-4bf9-b101-7da875a85fc8
TableOfContents()

# ╔═╡ ae9ff8c9-6076-4f25-a0b6-92c6842cd670
md"""## Selected APIs

"""

# ╔═╡ 5bb31e23-7095-4ada-ad60-ad165c49eed5
textapi = "https://www.sefaria.org/api/v3/texts/"

# ╔═╡ 90558f24-0f01-45de-b978-640e0bc3884e
indexapi = "https://www.sefaria.org/api/v2/raw/index/"

# ╔═╡ 0d47f25d-de13-4966-b6de-c7af1c79993f
calendarapi = "https://www.sefaria.org/api/calendars"

# ╔═╡ 57720510-8d19-4f1e-a7bb-ea09da43b90e
lexiconapi = "https://www.sefaria.org/api/words/"

# ╔═╡ 170fac20-1b41-4674-ab58-862e89f4e157
md"""## Utilities"""

# ╔═╡ 0ebc2165-d93d-4e2b-8232-f32a7126ce29
"""Download a URL and parse its contents as JSON3."""
function parse_url(u)
	   f = Downloads.download(u)

	   parsed = JSON3.read(f)
	   rm(f)
	   parsed
   end

# ╔═╡ a36e4504-f4b2-4b59-8cb6-7e38d1c409d0
"""Get Sefaria's full JSON data for today's portion."""
function parsha_json()
	json = parse_url(calendarapi)
	portion = filter(json.calendar_items) do i
	    i.title.en == "Parashat Hashavua"
	end
	if length(portion) != 1
		# maybe throw an error?
		@warn("Should have found 1 portion but got $(length(portion))")
		nothing
	else
		txt = textapi * HTTP.escapeuri(portion[1].ref)
		parse_url(txt)
	end
end

# ╔═╡ 536fa218-23f4-457d-bd41-caf2e0fbb15c
"""Get the text of today's portion."""
function parsha_text()
	json = parsha_json().versions
	text_data = map(v -> v.text, json)
	if length(text_data) == 1
		text_data[1]
	else
		@debug("Something went wrong: got the wrong number of elements when retrieving portion text.")
		nothing
	end
end

# ╔═╡ 88587a02-cd52-4cd6-ba66-30b5ec9ca7f5
"""Get the text of today's portion."""
function parsha_text_html()
	html_out = []
	for chapt in parsha_text()
		push!(html_out, "<p><b>Chapter</b></p><ol>")
		for verse in chapt
			push!(html_out, "<li>", verse, "</li>")
		end
		push!(html_out, "</ol>")
	end
	join(html_out,"\n")
end

# ╔═╡ e4273ace-98a2-4ce3-9baa-c7f62172a42e
md"""## Find the Parashat HaShavua (`https://www.sefaria.org/api/calendars`)"""

# ╔═╡ 9811387c-002d-4249-882d-1c1be26af86b
md"""The full JSON data set:"""

# ╔═╡ 09813b85-b24f-4912-ae79-907b7909f4ec
parsha = parsha_json()

# ╔═╡ a68e81c9-bb91-4c43-b6ca-0c969f0645bf
parsha.versions[1] |> println

# ╔═╡ a3821c5e-e130-4709-9968-6c5100b348bf
parsha.spanningRefs

# ╔═╡ b4aff48c-ccaf-4582-86e8-43d485896c51
parsha.sections

# ╔═╡ e1cdc87f-e6f2-4fba-8607-d0e2106125ad
parsha.toSections

# ╔═╡ bca1f4ef-8344-4b39-b79f-9ae42131a0d9
parsha.ref

# ╔═╡ 272bea93-d5d5-48c1-a15f-c0ef194e55e6
parsha.heRef

# ╔═╡ 2ecf16f4-1614-49de-85cc-c924c74a78e7
parsha |> println

# ╔═╡ 2a04fdbf-93ac-4a1e-a4b1-0086188a8c9c
md"A 2-tier vector of strings (chapters, verses):"

# ╔═╡ e4be98c2-4f1f-4fbd-92d8-602fa477af6b
parsha_text()

# ╔═╡ e41bb2a7-0cc3-4680-8f63-2471caadb116
md"""The text wrapped in HTML: `parsha_text_html()` (*Show output*: $(@bind showportion CheckBox()))"""

# ╔═╡ 90269a39-3415-466d-b047-fde83cf3e43b
if showportion
	"<hr/><h4>Portion for today</h4>" * parsha_text_html() |> HTML
end

# ╔═╡ 6984bef4-eacd-44a9-ad18-88a6c86f0911
parsha_json().versions[1]

# ╔═╡ d7186fa3-a689-4280-95be-a9ab44493da5
md"""## Index structure (`https://www.sefaria.org/api/v2/raw/index`)"""

# ╔═╡ a3ed09c6-2247-4fd6-96c6-6c70227772a0
idxurl = "https://www.sefaria.org/api/v2/raw/index/" * HTTP.escapeuri("Deuteronomy")

# ╔═╡ 6c2f205a-b005-42cf-bf75-c75710000f17
bookidx = parse_url(idxurl)


# ╔═╡ c7b785d7-8582-448c-afda-dfc98d293e93
bookidx.schema.titles[end]

# ╔═╡ 9f90a714-3834-473c-8c37-68983b68ab15
bookidx.schema.match_templates

# ╔═╡ 81c38cdb-ae2b-4af0-9283-c70e31a328e0
bookidx.schema.lengths

# ╔═╡ 98306465-cbd5-46a0-b511-4f507755a3f7
map(bookidx.schema.sectionNames) do n
	n
end

# ╔═╡ f29e07a2-67a3-4abf-9459-89290c22b46e
bookidx.schema

# ╔═╡ dd235d02-cd95-470b-8b04-f08e741501a3
md""" ## Maybe version structure? `https://www.sefaria.org/api/v3/texts`"""

# ╔═╡ 835da86b-2c21-4b24-9ac0-859bef101236
sampref = "deuteronomy:29.1-29.8" |> HTTP.escapeuri

# ╔═╡ 3415b8ea-a517-4c82-8e72-8c9f796791d3
 sampjson = (textapi * sampref |> parse_url)

# ╔═╡ db74a298-54f1-4b07-9b68-320f0c3e9c0a
sampversions = sampjson.versions

# ╔═╡ 8d99410f-70ec-4a9c-b459-879b10353577
sampversions[1]

# ╔═╡ 9c591453-2722-477e-9510-32127396e197
sampverse = "deuteronomy:29.7-29.8"

# ╔═╡ f7b43f44-b326-4170-bc12-1387033a7c0f
versejson = (textapi * sampverse |> parse_url)

# ╔═╡ 612a34ce-8292-4805-905e-ef9469f14c3d
versetext = map(v -> v.text, versejson.versions)

# ╔═╡ 7db5f75c-6fbd-4304-92d5-42186fa87baa
tkn = split(versetext[1][2])[1]


# ╔═╡ 0fe7364a-4d4f-4d5e-8602-33594e477ce0
md"""## Lexicon"""

# ╔═╡ 7b4ff200-1607-48c3-ad16-67e022f91241
join(parse_url(lexiconapi * tkn)[2].content.senses,"\n") |> HTML

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Downloads = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"
JSON3 = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
HTTP = "~1.10.8"
JSON3 = "~1.14.0"
PlutoUI = "~0.7.60"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.5"
manifest_format = "2.0"
project_hash = "328168ab25fc5f53f7e718e64be0bd754798d21c"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "0691e34b3bb8be9307330f88d1a3c3f25466c24d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.9"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "bce6804e5e6044c6daab27bb533d1295e4a2e759"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.6"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "ea32b83ca4fefa1768dc84e504cc0a94fb1ab8d1"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.4.2"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "dcb08a0d93ec0b1cdc4af184b26b591e9695423a"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.10"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "d1d712be3164d61d1fb98e7ce9bcbc6cc06b45ed"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.8"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "b6d6bfdd7ce25b0f9b2f6b3dd56b2673a66c8770"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.5"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "f389674c99bfcde17dc57454011aa44d5a260a40"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.6.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JSON3]]
deps = ["Dates", "Mmap", "Parsers", "PrecompileTools", "StructTypes", "UUIDs"]
git-tree-sha1 = "eb3edce0ed4fa32f75a0a11217433c31d56bd48b"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.14.0"

    [deps.JSON3.extensions]
    JSON3ArrowExt = ["ArrowTypes"]

    [deps.JSON3.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.4.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.6.4+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "c1dd6d7978c12545b4179fb6153b9250c96b0075"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.3"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "NetworkOptions", "Random", "Sockets"]
git-tree-sha1 = "c067a280ddc25f196b5e7df3877c6b226d390aaf"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.9"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+1"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.1.10"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.23+4"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "38cb508d080d21dc1128f7fb04f20387ed4c0af4"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.3"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1b35263570443fdd9e76c76b7062116e2f374ab8"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.0.15+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.10.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "eba4810d5e6a01f612b948c9fa94f905b49087b0"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.60"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.10.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.10.0"

[[deps.StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "159331b30e94d7b11379037feeb9b690950cace8"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.11.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.2.1+1"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
git-tree-sha1 = "e84b3a11b9bece70d14cce63406bbc79ed3464d2"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.2"

[[deps.Tricks]]
git-tree-sha1 = "7822b97e99a1672bfb1b49b668a6d46d58d8cbcb"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.9"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.52.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"
"""

# ╔═╡ Cell order:
# ╟─12c54c07-f2ef-427c-90ab-c1662fc07a25
# ╟─7782fefc-7774-11ef-25bf-1714acd3d1c1
# ╟─52088b63-d040-4bf9-b101-7da875a85fc8
# ╟─ae9ff8c9-6076-4f25-a0b6-92c6842cd670
# ╟─5bb31e23-7095-4ada-ad60-ad165c49eed5
# ╟─90558f24-0f01-45de-b978-640e0bc3884e
# ╟─0d47f25d-de13-4966-b6de-c7af1c79993f
# ╟─57720510-8d19-4f1e-a7bb-ea09da43b90e
# ╟─170fac20-1b41-4674-ab58-862e89f4e157
# ╟─0ebc2165-d93d-4e2b-8232-f32a7126ce29
# ╟─a36e4504-f4b2-4b59-8cb6-7e38d1c409d0
# ╟─536fa218-23f4-457d-bd41-caf2e0fbb15c
# ╟─88587a02-cd52-4cd6-ba66-30b5ec9ca7f5
# ╟─e4273ace-98a2-4ce3-9baa-c7f62172a42e
# ╟─9811387c-002d-4249-882d-1c1be26af86b
# ╟─09813b85-b24f-4912-ae79-907b7909f4ec
# ╠═a68e81c9-bb91-4c43-b6ca-0c969f0645bf
# ╠═a3821c5e-e130-4709-9968-6c5100b348bf
# ╠═b4aff48c-ccaf-4582-86e8-43d485896c51
# ╠═e1cdc87f-e6f2-4fba-8607-d0e2106125ad
# ╠═bca1f4ef-8344-4b39-b79f-9ae42131a0d9
# ╠═272bea93-d5d5-48c1-a15f-c0ef194e55e6
# ╠═2ecf16f4-1614-49de-85cc-c924c74a78e7
# ╟─2a04fdbf-93ac-4a1e-a4b1-0086188a8c9c
# ╠═e4be98c2-4f1f-4fbd-92d8-602fa477af6b
# ╟─e41bb2a7-0cc3-4680-8f63-2471caadb116
# ╟─90269a39-3415-466d-b047-fde83cf3e43b
# ╠═6984bef4-eacd-44a9-ad18-88a6c86f0911
# ╟─d7186fa3-a689-4280-95be-a9ab44493da5
# ╠═a3ed09c6-2247-4fd6-96c6-6c70227772a0
# ╠═6c2f205a-b005-42cf-bf75-c75710000f17
# ╠═c7b785d7-8582-448c-afda-dfc98d293e93
# ╠═9f90a714-3834-473c-8c37-68983b68ab15
# ╠═81c38cdb-ae2b-4af0-9283-c70e31a328e0
# ╠═98306465-cbd5-46a0-b511-4f507755a3f7
# ╠═f29e07a2-67a3-4abf-9459-89290c22b46e
# ╟─dd235d02-cd95-470b-8b04-f08e741501a3
# ╠═835da86b-2c21-4b24-9ac0-859bef101236
# ╠═db74a298-54f1-4b07-9b68-320f0c3e9c0a
# ╠═8d99410f-70ec-4a9c-b459-879b10353577
# ╠═3415b8ea-a517-4c82-8e72-8c9f796791d3
# ╠═9c591453-2722-477e-9510-32127396e197
# ╠═f7b43f44-b326-4170-bc12-1387033a7c0f
# ╠═612a34ce-8292-4805-905e-ef9469f14c3d
# ╠═7db5f75c-6fbd-4304-92d5-42186fa87baa
# ╠═0fe7364a-4d4f-4d5e-8602-33594e477ce0
# ╠═7b4ff200-1607-48c3-ad16-67e022f91241
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
