use "reactive_streams"
use "../reactive-elements"
use "ponytest"
use "random"


actor _UnboundedTestSubscriber is Subscriber[U32]
    let helper: TestHelper
    let name: String
    new create(h: TestHelper, name': String) =>
        helper = h
        name = name'
    be on_subscribe(s: Subscription iso) =>
        helper.complete_action(name + "_subscribe")
        s.request(U64.max_value())
    be on_next(a: U32) =>
        helper.complete_action(name + "_next_" + a.string())
    be on_complete() =>
        helper.complete_action(name + "_complete")

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
        

primitive _PublisherSequenceTest is TestWrapped
	fun all_tests(): Array[UnitTest iso] =>
		[as UnitTest iso:

object iso is UnitTest
	fun name(): String => "sequence / unbounded"
	fun apply(h: TestHelper) =>
        h.long_test(1_000_000_000)
        let undertest = SequenceProducer(0, 5, 1)
        h.expect_action("basic_subscribe")
        h.expect_action("basic_next_0")
        h.expect_action("basic_next_1")
        h.expect_action("basic_next_2")
        h.expect_action("basic_next_3")
        h.expect_action("basic_next_4")
        h.expect_action("basic_complete")
        undertest.subscribe(_UnboundedTestSubscriber(h, "basic"))
end

object iso is UnitTest
	fun name(): String => "sequence / single"
	fun apply(h: TestHelper) =>
        h.long_test(1_000_000_000)
        let undertest = SequenceProducer(0, 5, 1)
        h.expect_action("basic_subscribe")
        h.expect_action("basic_next_0")
        h.expect_action("basic_next_1")
        h.expect_action("basic_next_2")
        h.expect_action("basic_next_3")
        h.expect_action("basic_next_4")
        h.expect_action("basic_complete")
        undertest.subscribe(_SingleTestSubscriber(h, "basic"))
end
]
