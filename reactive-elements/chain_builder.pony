use "reactive_streams"

// "transform" / "extract"

class val ChainBuilder[I: Any #share] is (
    ChainBuilderMap[I] 
    & ChainBuilderEach[I]
    & ChainBuilderSubscription[I]
    )

    let p: Publisher[I]

    new val from(p': Publisher[I]) =>
        p = p'

    fun box _publisher(): Publisher[I] => p

    fun using[O: Any #share](supplier: {(Publisher[I]): Processor[I, O]} iso): ChainBuilder[O] =>
        ChainBuilder[O].from(supplier(p))

    fun val transform[O: Any #share](transformer: {(ChainBuilder[I] val): ChainBuilder[O] val} iso): ChainBuilder[O] =>
        transformer(this)
