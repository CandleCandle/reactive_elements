use "reactive_streams"
use "../reactive-elements"
use "ponytest"
use "files"




primitive _FilePublisherTest is TestWrapped
	fun all_tests(): Array[UnitTest iso] =>
		[as UnitTest iso:

object iso is UnitTest
	fun name(): String => "file / publish"
	fun apply(h: TestHelper) ? =>
        h.long_test(1_000_000_000)

        let file_name = "test/fixtures/file_blob.txt"
        let undertest = FilePublisher(FilePath(h.env.root as AmbientAuth, file_name)?, 4)

        h.expect_action("file_subscribe")
        h.expect_action("file_next_blob")
        h.expect_action("file_next_ of ")
        h.expect_action("file_next_text")
        h.expect_action("file_complete")

        let mp = MapProcessor[Array[U8] val, String val](undertest, {(a): String => String.from_array(a)})
        mp.subscribe(_UnboundedTestSubscriber[String](h, "file"))
end

]
