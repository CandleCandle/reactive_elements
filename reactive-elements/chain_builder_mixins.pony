use "reactive_streams"

trait ChainBuilderMixin[I: Any #share]
    fun box _publisher(): Publisher[I]

trait ChainBuilderMap[I: Any #share] is ChainBuilderMixin[I]
    fun map[O: Any #share](action: {(I): O ?} iso): ChainBuilder[O] =>
        ChainBuilder[O].from(MapProcessor[I, O](_publisher(), consume action))


trait ChainBuilderEach[I: Any #share] is ChainBuilderMixin[I]
    fun onEach(action: {(I): I ?} iso): ChainBuilder[I] =>
        ChainBuilder[I].from(EachProcessor[I](_publisher(), consume action))


trait ChainBuilderSubscription[I: Any #share] is ChainBuilderMixin[I]
    fun subscribe(subscriber: Subscriber[I]) =>
        _publisher().subscribe(subscriber)

    fun subscribe_when() =>
        """
        count of subscribers?
        predicate?
        signal from another publisher?
        """



