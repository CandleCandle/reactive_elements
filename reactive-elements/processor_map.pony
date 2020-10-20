use "reactive_streams"

// Processor[A: Any #share, B: Any #share] is (Subscriber[A] & Publisher[B])

actor MapProcessor[I: Any #share, O: Any #share] is Processor[I, O]

    let publisher: Publisher[I]
    let action: {(I): O} iso
    var subscriber: (None | Subscriber[O]) = None

    new create(publisher': Publisher[I], action': {(I): O} iso) =>
        publisher = publisher'
        action = consume action'

    be subscribe(s: Subscriber[O]) =>
        subscriber = s
        publisher.subscribe(this)

    be on_subscribe(s: Subscription iso) =>
        try (subscriber as Subscriber[O]).on_subscribe(consume s) end

    be on_next(a: I) =>
        try (subscriber as Subscriber[O]).on_next(action(consume a)) end

    be on_error(e: ReactiveError) =>
        try (subscriber as Subscriber[O]).on_error(e) end

    be on_complete() =>
        try (subscriber as Subscriber[O]).on_complete() end
