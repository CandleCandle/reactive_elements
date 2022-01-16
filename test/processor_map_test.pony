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
        let undertest = MapProcessor[U32, U64].unicast(pub, {(i: U32) => (i * 2).u64()})

        h.expect_action("map-x2_subscribe")
        h.expect_action("map-x2_next_8")
        h.expect_action("map-x2_next_12")
        h.expect_action("map-x2_next_6")
        h.expect_action("map-x2_next_4")
        h.expect_action("map-x2_complete")

        let sub = _UnboundedTestSubscriber[U64](h, "map-x2")
        undertest.subscribe(sub)
end

]
