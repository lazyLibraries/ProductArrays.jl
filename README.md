# ProductArrays

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://lazyLibraries.github.io/ProductArrays.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://lazyLibraries.github.io/ProductArrays.jl/dev/)
[![Build Status](https://github.com/lazyLibraries/ProductArrays.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/lazyLibraries/ProductArrays.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/lazyLibraries/ProductArrays.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/lazyLibraries/ProductArrays.jl)


The ProductArrays is a lazy form of
```julia
collect(Iterators.product(vectors...))
```
i.e. it is an `AbstractArray` in contrast to `Iterators.product(vectors...)`. So
is accessible with `getindex` and gets default Array implementations for free.
In particular it can be passed to `Base.PermutedDimsArray` for lazy permutation
and `vec()` to obtain a lazy `Base.ReshapedArray`.

## Examples:

```julia
julia> A = productArray(1:3, (:a,:b))
3×2 ProductArrays.ProductArray{Tuple{UnitRange{Int64}, Tuple{Symbol, Symbol}}, Tuple{Int64, Symbol}, 2}:
 (1, :a)  (1, :b)
 (2, :a)  (2, :b)
 (3, :a)  (3, :b)

julia> vec(A)
6-element reshape(::ProductArrays.ProductArray{Tuple{UnitRange{Int64}, Tuple{Symbol, Symbol}}, Tuple{Int64, Symbol}, 2}, 6) with eltype Tuple{Int64, Symbol}:
 (1, :a)
 (2, :a)
 (3, :a)
 (1, :b)
 (2, :b)
 (3, :b)

julia> sizeof(A) == sizeof(1:3) + sizeof((:a,:b))
true

julia> A == collect(Iterators.product(1:3, (:a,:b)))
true
```

## Related Packages

A list compiled by Alexander Plavin (@aplavin)

### Packages focusing on grids/products specifically

- [StructuredGrids.jl](https://github.com/haampie/StructuredGrids.jl) (the same promise but [fails on edge cases](https://github.com/haampie/StructuredGrids.jl/issues/2))
- [LazyGrids.jl](https://github.com/JuliaArrays/LazyGrids.jl) (does something
else: tuple of grids not grid of tuples)
- [RectiGrids.jl](https://gitlab.com/aplavin/RectiGrids.jl) (focus on
keyed/labeled arrays - fails on the same edge cases as `StructuredGrids.jl`)

### Parts of other packages

- [ProductView](https://github.com/JuliaData/SplitApplyCombine.jl#productviewf-a-b) of [SplitApplyCombine.jl](https://github.com/JuliaData/SplitApplyCombine.jl)
- [[WIP] ProductedArrays JuliaArrays/MappedArrays.jl#42](https://github.com/JuliaArrays/MappedArrays.jl/pull/42)
