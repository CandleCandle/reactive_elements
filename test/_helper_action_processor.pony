use "reactive_streams"
use "pony_test"

actor _HelperActionProcessor[A: Any val] is Processor[A, A]
    let helper: TestHelper
    let name: String
    let publisher: Publisher[A]
    var subscriber: (None | Subscriber[A]) = None
    new create(publisher': Publisher[A], h: TestHelper, name': String) =>
        publisher = publisher'
        helper = h
        name = name'
    be subscribe(s: Subscriber[A]) =>
        helper.complete_action(name + "_subscribe")
        subscriber = s
        publisher.subscribe(this)
    be on_subscribe(s: Subscription iso) =>
        helper.complete_action(name + "_on_subscribe")
        try (subscriber as Subscriber[A]).on_subscribe(consume s) end
    be on_next(a: A) =>
        match a
        | let a': Stringable val =>
            helper.complete_action(name + "_next_" + a'.string())
        else
            helper.complete_action(name + "_next_?")
        end
        try (subscriber as Subscriber[A]).on_next(consume a) end
    be on_complete() =>
        helper.complete_action(name + "_complete")
        try (subscriber as Subscriber[A]).on_complete() end
    be on_error(e: ReactiveError) =>
        match e
        | let e': Stringable val =>
            helper.complete_action(name + "_error_" + e'.string())
        else
            helper.complete_action(name + "_error_?")
        end
        try (subscriber as Subscriber[A]).on_error(e) end
