using ProductArrays
using Documenter

DocMeta.setdocmeta!(ProductArrays, :DocTestSetup, :(using ProductArrays); recursive=true)

makedocs(;
    modules=[ProductArrays],
    authors="Felix Benning <felix.benning@gmail.com> and contributors",
    repo="https://github.com/lazyLibraries/ProductArrays.jl/blob/{commit}{path}#{line}",
    sitename="ProductArrays.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://lazyLibraries.github.io/ProductArrays.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/lazyLibraries/ProductArrays.jl",
    devbranch="main",
)
