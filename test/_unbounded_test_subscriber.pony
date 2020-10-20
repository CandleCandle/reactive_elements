use "reactive_streams"
use "ponytest"

actor _UnboundedTestSubscriber[A: Any val] is Subscriber[A]
    let helper: TestHelper
    let name: String
    new create(h: TestHelper, name': String) =>
        helper = h
        name = name'
    be on_subscribe(s: Subscription iso) =>
        helper.complete_action(name + "_subscribe")
        s.request(U64.max_value())
    be on_next(a: A) =>
        match a
        | let a': Stringable val => 
            helper.complete_action(name + "_next_" + a'.string())
        else
            helper.complete_action(name + "_next_?")
        end
    be on_complete() =>
        helper.complete_action(name + "_complete")
