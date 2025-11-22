using Bincrypter
using Documenter

DocMeta.setdocmeta!(Bincrypter, :DocTestSetup, :(using Bincrypter); recursive=true)

makedocs(;
    modules=[Bincrypter],
    authors="imohag9 <souidi.hamza90@gmail.com> and contributors",
    sitename="Bincrypter.jl",
    format=Documenter.HTML(;
        canonical="https://imohag9.github.io/Bincrypter.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "API Reference" => "api.md",
        ],
)

deploydocs(;
    repo="github.com/imohag9/Bincrypter.jl",
    devbranch="main",
)
