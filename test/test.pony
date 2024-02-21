use "pony_test"


actor Main is TestList
	new create(env: Env) =>
		PonyTest(env, this)
	new make() => None
	fun tag tests(test: PonyTest) =>
		TestWrapper.tests(_PublisherSequenceTest, test)
		TestWrapper.tests(_ProcessorMapTest, test)
		TestWrapper.tests(_ChainBuilderTest, test)
		TestWrapper.tests(_FilePublisherTest, test)

trait TestWrapped
	fun all_tests(): Array[UnitTest iso]

actor TestWrapper
	fun tag tests(wrapped: TestWrapped val, test: PonyTest) =>
		let tests' = wrapped.all_tests()
		while tests'.size() > 0 do
			try test(tests'.pop()?) end
		end
