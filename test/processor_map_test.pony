use "reactive_streams"
use "../reactive-elements"
use "ponytest"
use "random"




primitive _ProcessorMapTest is TestWrapped
	fun all_tests(): Array[UnitTest iso] =>
		[as UnitTest iso:

object iso is UnitTest
	fun name(): String => "map / x2"
	fun apply(h: TestHelper) =>
        h.long_test(1_000_000_000)

        let pub = ArrayPublisher[U32]([as U32: 4; 6; 3; 2])
        let undertest = MapProcessor[U32, U64]({(i: U32) => (i * 2).u64()})
        let sub = _UnboundedTestSubscriber[U64](h, "map-x2")

        h.expect_action("basic_subscribe")
        h.expect_action("basic_next_8")
        h.expect_action("basic_next_12")
        h.expect_action("basic_next_6")
        h.expect_action("basic_next_4")
        h.expect_action("basic_complete")

        undertest.subscribe(sub)
        pub.subscribe(undertest)
end

]
