use "reactive_streams"

primitive MapReactiveError is ReactiveError

actor MapProcessor[I: Any #share, O: Any #share] is Processor[I, O]

    let publisher: Publisher[I]
    let action: {(I): O ?} iso
    var subscriber: (None | Subscriber[O]) = None

    new create(publisher': Publisher[I], action': {(I): O ?} iso) =>
        publisher = publisher'
        action = consume action'

    be subscribe(s: Subscriber[O]) =>
        subscriber = s
        publisher.subscribe(this)

    be on_subscribe(s: Subscription iso) =>
        try (subscriber as Subscriber[O]).on_subscribe(consume s) end

    be on_next(a: I) =>
        match subscriber
        | let s: Subscriber[O] =>
            try
                s.on_next(action(consume a)?)
            else
                s.on_error(EachReactiveError)
            end
        end

    be on_error(e: ReactiveError) =>
        try (subscriber as Subscriber[O]).on_error(e) end

    be on_complete() =>
        try (subscriber as Subscriber[O]).on_complete() end
