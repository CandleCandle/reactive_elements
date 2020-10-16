use "reactive_streams"
use "../reactive-elements"
use "ponytest"
use "random"


actor _SingleTestSubscriber is Subscriber[U32]
    let helper: TestHelper
    let name: String
    var sub: (None | Subscription) = None
    new create(h: TestHelper, name': String) =>
        helper = h
        name = name'
    be on_subscribe(s: Subscription iso) =>
        helper.complete_action(name + "_subscribe")
        sub = consume s
        match sub
        | let sub': Subscription => sub'.request(1)
        end
    be on_next(a: U32) =>
        helper.complete_action(name + "_next_" + a.string())
        match sub
        | let sub': Subscription => sub'.request(1)
        end
    be on_complete() =>
        helper.complete_action(name + "_complete")
        sub = None
        
actor _CancellingTestSubscriber is Subscriber[U32]
    let helper: TestHelper
    let name: String
    var sub: (None | Subscription) = None
    new create(h: TestHelper, name': String) =>
        helper = h
        name = name'
    be on_subscribe(s: Subscription iso) =>
        helper.complete_action(name + "_subscribe")
        sub = consume s
        match sub
        | let sub': Subscription => sub'.request(1)
        end
    be on_next(a: U32) =>
        helper.complete_action(name + "_next_" + a.string())
        match sub
        | let sub': Subscription =>
            if a > 1 then sub'.cancel() end
            sub'.request(1)
        end
    be on_complete() =>
        helper.complete_action(name + "_complete")
        
actor _CancellingUnboundedTestSubscriber is Subscriber[U32]
    let helper: TestHelper
    let name: String
    var sub: (None | Subscription) = None
    new create(h: TestHelper, name': String) =>
        helper = h
        name = name'
    be on_subscribe(s: Subscription iso) =>
        helper.complete_action(name + "_subscribe")
        sub = consume s
        match sub
        | let sub': Subscription => sub'.request(U64.max_value())
        end
    be on_next(a: U32) =>
        helper.complete_action(name + "_next_" + a.string())
        match sub
        | let sub': Subscription =>
            if a > 1 then sub'.cancel() end
        end
    be on_complete() =>
        helper.complete_action(name + "_complete")

primitive _PublisherSequenceTest is TestWrapped
	fun all_tests(): Array[UnitTest iso] =>
		[as UnitTest iso:

object iso is UnitTest
	fun name(): String => "sequence / unbounded"
	fun apply(h: TestHelper) =>
        h.long_test(1_000_000_000)
        let undertest = SequencePublisher(0, 5, 1)
        h.expect_action("basic_subscribe")
        h.expect_action("basic_next_0")
        h.expect_action("basic_next_1")
        h.expect_action("basic_next_2")
        h.expect_action("basic_next_3")
        h.expect_action("basic_next_4")
        h.expect_action("basic_complete")
        undertest.subscribe(_UnboundedTestSubscriber[U32](h, "basic"))
end

object iso is UnitTest
	fun name(): String => "sequence / single"
	fun apply(h: TestHelper) =>
        h.long_test(1_000_000_000)
        let undertest = SequencePublisher(0, 5, 1)
        h.expect_action("basic_subscribe")
        h.expect_action("basic_next_0")
        h.expect_action("basic_next_1")
        h.expect_action("basic_next_2")
        h.expect_action("basic_next_3")
        h.expect_action("basic_next_4")
        h.expect_action("basic_complete")
        undertest.subscribe(_SingleTestSubscriber(h, "basic"))
end

object iso is UnitTest
	fun name(): String => "sequence / cancel"
	fun apply(h: TestHelper) =>
        h.long_test(1_000_000_000)
        let undertest = SequencePublisher(0, 5, 1)
        h.expect_action("basic_subscribe")
        h.expect_action("basic_next_0")
        h.expect_action("basic_next_1")
        // h.expect_action("basic_cancel")
        undertest.subscribe(_CancellingTestSubscriber(h, "basic"))
end

object iso is UnitTest
	fun name(): String => "sequence / cancel / unbounded"
	fun apply(h: TestHelper) =>
        h.long_test(1_000_000_000)
        let undertest = SequencePublisher(0, 5, 1)
        h.expect_action("basic_subscribe")
        h.expect_action("basic_next_0")
        h.expect_action("basic_next_1")
        // h.expect_action("basic_cancel")
        // Asynchronous nature of the actor means that
        // the following actions may or may not occur
        // therefore subscribers should be aware that
        // they may get data after they have seen a
        // 'cancel'.
        // h.expect_action("basic_next_2")
        // h.expect_action("basic_next_3")
        // h.expect_action("basic_next_4")
        // h.expect_action("basic_complete")
        undertest.subscribe(_CancellingTestSubscriber(h, "basic"))
end
]
