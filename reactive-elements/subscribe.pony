use "reactive_streams"


trait ChainBuilderSubscription[I: Any #share] is ChainBuilderMixin[I]
    fun subscribe(subscriber: Subscriber[I]) =>
        _publisher().subscribe(subscriber)

    fun subscribe_when() =>
        """
        count of subscribers?
        predicate?
        signal from another publisher?
        """

