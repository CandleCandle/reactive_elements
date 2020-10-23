use "reactive_streams"
use "../reactive-elements"
use "ponytest"
use "random"




primitive _ChainBuilderTest is TestWrapped
	fun all_tests(): Array[UnitTest iso] =>
		[as UnitTest iso:

object iso is UnitTest
	fun name(): String => "chain / using+map+subscribe"
	fun apply(h: TestHelper) =>
        h.long_test(1_000_000_000)

        h.expect_action("input_subscribe")
        h.expect_action("input_next_3")
        h.expect_action("input_next_7")
        h.expect_action("input_complete")
        h.expect_action("output_subscribe")
        h.expect_action("output_next_6")
        h.expect_action("output_next_14")
        h.expect_action("output_complete")
        h.expect_action("sub_subscribe")
        h.expect_action("sub_next_6")
        h.expect_action("sub_next_14")
        h.expect_action("sub_complete")

        ChainBuilder[U32].from(ArrayPublisher[U32]([as U32: 3; 7]))
                .using[U32]({(p: Publisher[U32]): Processor[U32, U32] => _HelperActionProcessor[U32].create(p, h, "input")})
                .map[U64]({(i: U32) => (i * 2).u64()})
                .using[U64]({(p: Publisher[U64]): Processor[U64, U64] => _HelperActionProcessor[U64].create(p, h, "output")})
                .subscribe(_UnboundedTestSubscriber[U64](h, "sub"))
end

]
