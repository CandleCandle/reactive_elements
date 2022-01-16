use "reactive_streams"

primitive MapReactiveError is ReactiveError


trait ChainBuilderMap[I: Any #share] is ChainBuilderMixin[I]
    fun map_b[O: Any #share](action: {(I): O ?} iso): ChainBuilder[O] =>
        """
        Convert one type to another. Allowing multiple subscribers
        """
        ChainBuilder[O].from(MapProcessor[I, O].broadcast(_publisher(), consume action))

    fun map_u[O: Any #share](action: {(I): O ?} iso): ChainBuilder[O] =>
        """
        Convert one type to another. Allowing a single subscriber
        """
        ChainBuilder[O].from(MapProcessor[I, O].unicast(_publisher(), consume action))


actor MapProcessor[I: Any #share, O: Any #share] is (Subscriber[I] & ManagedPublisher[O])

    let publisher: Publisher[I]
    let action: {(I): O ?} iso
    var _subscription: ( None | Subscription iso ) = None
    var _requested: U64 = 0

    let _subscriber_manager': SubscriberManager[O]

    new broadcast(publisher': Publisher[I], action': {(I): O ?} iso) =>
        publisher = publisher'
        action = consume action'
        _subscriber_manager' = Broadcast[O].create(this)

    new unicast(publisher': Publisher[I], action': {(I): O ?} iso) =>
        publisher = publisher'
        action = consume action'
        _subscriber_manager' = Unicast[O].create(this)

    fun ref _subscriber_manager(): SubscriberManager[O] =>
        _subscriber_manager'

    be on_next(a: I) =>
        try
            _subscriber_manager().publish(action(consume a)?)
        else
            _subscriber_manager().on_error(EachReactiveError)
        end

    be on_error(e: ReactiveError) =>
        _subscriber_manager().on_error(e)

    be on_complete() =>
        _subscriber_manager().on_complete()

    be on_subscribe(subscription': Subscription iso) =>
        _subscription = consume subscription'
        if (_requested > 0) then
            try (_subscription as Subscription iso).request(_requested) end
            _requested = 0
        end

    be subscribe(s: Subscriber[O]) =>
        // causes a race condition between the two behaviours;
        // requiring the stashing of '_requested'.
        // if the 'subscriber_manager' completes first, requesting
        // events then 'subscription' is None; causing 'on_request'
        // to not request items from the publisher.
        publisher.subscribe(this)
        _subscriber_manager().on_subscribe(s)

    be on_request(s: Subscriber[O], n: U64) =>
        _subscriber_manager().on_request(s, n)
        try // TODO convert this into a 'match'
            (_subscription as Subscription iso).request(_subscriber_manager().max_request())
        else
            // publisher.subscribe(this) has yet to complete.
            // Stash the total requsted so far so that it
            // can be requested when we receive an 'on_subscribe'
            // event
            _requested = _subscriber_manager().max_request()
        end

    be on_cancel(s: Subscriber[O]) =>
        _subscriber_manager().on_cancel(s)
