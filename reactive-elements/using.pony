use "reactive_streams"


trait ChainBuilderUsing[I: Any #share] is ChainBuilderMixin[I]
    fun using[O: Any #share](supplier: {(Publisher[I]): Processor[I, O]} iso): ChainBuilder[O] =>
        ChainBuilder[O].from(supplier(_publisher()))

