module ProductArrays

export productArray

function _ensure_getindex(vecs::T) where {T<:Tuple}
    linear_indexed = ntuple(
        n -> hasmethod(Base.getindex, (fieldtype(T, n), Int)),
        Base._counttuple(T)
    )
    all(linear_indexed) || throw(ArgumentError(
        "$(vecs[findfirst(x->!x, linear_indexed)]) cannot be linearly accessed. All inputs need to implement `Base.getindex(::T, ::Int)`"
    ))
end
function _has_shape(T::Type)
    S = Base.IteratorSize(T)
    return S isa Base.HasLength || S isa Base.HasShape || T isa AbstractArray || hasmethod(Base.ndims, (T,))
end
function _ensure_shape(::T) where {T<:Tuple}
    all(ntuple(n -> _has_shape(fieldtype(T, n)), Base._counttuple(T))) || throw(ArgumentError(
        "The input is not an AbstractArray, does not implement ndims and its IteratorSize is neither Base.HasLength nor Base.HasShape. So ProductArray cannot figure out its shape"
    ))
end

index_dim(v) = index_dim(Base.IteratorSize(typeof(v)), v)
index_dim(::Base.HasShape{N}, v) where {N} = N
index_dim(::Base.HasLength, v) = 1
index_dim(::ST, v::AbstractArray{T,N}) where {ST<:Union{Base.IsInfinite,Base.SizeUnknown},T,N} = N
index_dim(::ST, v) where {ST<:Union{Base.IsInfinite,Base.SizeUnknown}} = ndim(v)

_ndims(p::Iterators.ProductIterator{T}) where {T<:Tuple} = _ndims(Base.IteratorSize(Iterators.ProductIterator{T}), p)
_ndims(::Base.HasLength, p::Iterators.ProductIterator) = ndims(p)
_ndims(::Base.HasShape, p::Iterators.ProductIterator) = ndims(p)
# Iterators.product is too conservative for ndims
_ndims(_, p::Iterators.ProductIterator) = sum(v -> index_dim(v), p.iterators)

struct ProductArray{T<:Tuple,Eltype,N} <: AbstractArray{Eltype,N}
    prodIt::Iterators.ProductIterator{T}
    ProductArray(t::T) where {T} = begin
        _ensure_getindex(t)
        _ensure_shape(t)
        prodIt = Iterators.ProductIterator(t)
        new{T,eltype(Iterators.ProductIterator{T}),_ndims(prodIt)}(prodIt)
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

# implement private _getindex for ProductIterator


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
In particular it can be passed to `Base.PermutedDimsArray` for lazy permutation
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

if VERSION >= v"1.8" # compatibility
    Base.last(p::ProductArray) = last(p.prodIt)
end

end
