module ProductArrays

export productArray

function _ensure_all_linear_indexed(vecs::T) where {T<:Tuple}
    linear_indexed = ntuple(
        n -> hasmethod(Base.getindex, (fieldtype(T, n), Int)),
        Base._counttuple(T)
    )
    all(linear_indexed) || throw(ArgumentError(
        "$(vecs[findfirst(x->!x, linear_indexed)]) cannot be linearly accessed. All inputs need to implement `Base.getindex(::T, ::Int)`"
    ))
end

struct ProductArray{T<:Tuple,Eltype,N} <: AbstractArray{Eltype,N}
    prodIt::Iterators.ProductIterator{T}
    ProductArray(t::T) where {T} = begin
        _ensure_all_linear_indexed(t)
        prodIt = Iterators.ProductIterator(t)
        new{T,eltype(Iterators.ProductIterator{T}),ndims(prodIt)}(prodIt)
    end
end

# wrap ProductIterator
function Base.IteratorSize(::Type{ProductArray{T,Eltype,N}}) where {T,Eltype,N}
    Base.IteratorSize(Iterators.ProductIterator{T})
end
Base.size(p::ProductArray) = size(p.prodIt)
Base.axes(p::ProductArray) = axes(p.prodIt)
Base.ndims(::ProductArray{T,Eltype,N}) where {T,Eltype,N} = N
Base.length(p::ProductArray) = length(p.prodIt)
function Base.IteratorEltype(::Type{<:ProductArray{T}}) where {T}
    Base.IteratorEltype(Iterators.ProductIterator{T})
end
Base.eltype(::Type{ProductArray{T,Eltype,N}}) where {T,Eltype,N} = Eltype
Base.iterate(p::ProductArray) = iterate(p.prodIt)
Base.iterate(p::ProductArray, state) = iterate(p.prodIt, state)

Base.last(p::ProductArray) = last(p.prodIt)

# implement private _getindex for ProductIterator

index_dim(v) = index_dim(Base.IteratorSize(typeof(v)), v)
index_dim(::Base.HasShape{N}, v) where {N} = N
index_dim(::Base.HasLength, v) = 1
index_dim(::ST, v::AbstractArray{T,N}) where {ST<:Union{Base.IsInfinite,Base.SizeUnknown},T,N} = N
function index_dim(::T, v) where {T<:Union{Base.IsInfinite,Base.SizeUnknown}}
    try
        return ndim(v)
    catch
        throw(ArgumentError("ProductArray cannot deal with $(typeof(v)) as its IteratorSize is of type $T and it does not implement `ndim`."))
    end
end

function _getindex(prod::Iterators.ProductIterator, indices::Int...)
    return _prod_getindex(prod.iterators, indices...)
end
_prod_getindex(::Tuple{}) = ()
function _prod_getindex(p_vecs::Tuple, indices::Int...)
    v = first(p_vecs)
    n = index_dim(v)
    return (
        v[indices[1:n]...],
        _prod_getindex(Base.tail(p_vecs), indices[n+1:end]...)...
    )
end

# apply this to ProductArray
Base.getindex(p::ProductArray{T,Eltype,N}, indices::Vararg{Int,N}) where {T,Eltype,N} = _getindex(p.prodIt, indices...)

"""
    productArray(vectors...)

The output is a lazy form of
```julia
collect(Iterators.product(vectors...))
```
i.e. it is an AbstractArray in contrast to `Iterators.product(vectors...)`. So
is accessible with `getindex` and gets default Array implementations for free.
In particular it can be passed to `Base.PermutedDimsArray`` for lazy permutation
and `vec()` to obtain a lazy `Base.ReshapedArray`.

Examples:
```jldoctest
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
"""
productArray(vectors...) = ProductArray(vectors)

if VERSION < 1.8 # compatibility
    Base.lastindex(p::ProductArray) = length(p)
end

end
