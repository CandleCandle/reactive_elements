use "reactive_streams"


trait ChainBuilderMixin[I: Any #share]
    fun box _publisher(): Publisher[I]


class val ChainBuilder[I: Any #share] is
    ( ChainBuilderMap[I] 
    & ChainBuilderEach[I]
    & ChainBuilderSubscription[I]
    & ChainBuilderTransform[I]
    & ChainBuilderUsing[I]
    )

    let p: Publisher[I]

    new val from(p': Publisher[I]) =>
        p = p'

    fun box _publisher(): Publisher[I] => p
    fun val _this(): ChainBuilder[I] => this
