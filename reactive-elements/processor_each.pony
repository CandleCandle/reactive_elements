use "reactive_streams"

primitive EachReactiveError is ReactiveError

actor EachProcessor[I: Any #share] is Processor[I, I]

    let publisher: Publisher[I]
    let action: {(I): I ?} iso
    var subscriber: (None | Subscriber[I]) = None

    new create(publisher': Publisher[I], action': {(I): I ?} iso) =>
        """
        Side-effect processor. The action should return the
        input verbatim
        no-op action might look like:
        {(input: I: Any #share): I => consume input}
        """
        publisher = publisher'
        action = consume action'

    be subscribe(s: Subscriber[I]) =>
        subscriber = s
        publisher.subscribe(this)

    be on_subscribe(s: Subscription iso) =>
        try (subscriber as Subscriber[I]).on_subscribe(consume s) end

    be on_next(a: I) =>
        match subscriber
        | let s: Subscriber[I] =>
            try
                s.on_next(action(consume a)?)
            else
                s.on_error(EachReactiveError)
            end
        end

    be on_error(e: ReactiveError) =>
        try (subscriber as Subscriber[I]).on_error(e) end

    be on_complete() =>
        try (subscriber as Subscriber[I]).on_complete() end


