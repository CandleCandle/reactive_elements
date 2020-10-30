use "reactive_streams"

// "transform" / "extract"

class val ChainBuilder[I: Any #share]
    let p: Publisher[I]

    new val from(p': Publisher[I]) =>
        p = p'

    fun map[O: Any #share](action: {(I): O ?} iso): ChainBuilder[O] =>
        ChainBuilder[O].from(MapProcessor[I, O](p, consume action))

    fun onEach(action: {(I): I ?} iso): ChainBuilder[I] =>
        ChainBuilder[I].from(EachProcessor[I](p, consume action))

    fun using[O: Any #share](supplier: {(Publisher[I]): Processor[I, O]} iso): ChainBuilder[O] =>
        ChainBuilder[O].from(supplier(p))

    fun val transform[O: Any #share](transformer: {(ChainBuilder[I] val): ChainBuilder[O] val} iso): ChainBuilder[O] =>
        transformer(this)

    fun subscribe(subscriber: Subscriber[I]) =>
        p.subscribe(subscriber)

    fun subscribe_when() =>
        """
        count of subscribers?
        predicate?
        signal from another publisher?
        """
