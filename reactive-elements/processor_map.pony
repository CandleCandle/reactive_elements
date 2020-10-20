use "reactive_streams"

// Processor[A: Any #share, B: Any #share] is (Subscriber[A] & Publisher[B])

actor MapProcessor[A: Any #share, B: Any #share] is Processor[A, B]

    let action: {(A): B} iso

    new create(action': {(A): B} iso) =>
        action = consume action'

    be subscribe(s: Subscriber[B]) =>
        None

    be on_subscribe(s: Subscription iso) =>
        None

    be on_next(a: A) =>
        None

    be on_error(e: ReactiveError) =>
        None

    be on_complete() =>
        None
