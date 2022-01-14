use "reactive_streams"


trait ChainBuilderTransform[I: Any #share] is ChainBuilderMixin[I]
	fun val _this(): ChainBuilder[I]

    fun val transform[O: Any #share](transformer: {(ChainBuilder[I] val): ChainBuilder[O] val} iso): ChainBuilder[O] =>
        transformer(_this())
