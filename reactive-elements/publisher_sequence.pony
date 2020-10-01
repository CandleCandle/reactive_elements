use "reactive_streams"


actor SequenceProducer is Publisher[U32]
    let start: U32
    let finish: U32
    let step: U32

    new create(start': U32 = 0, finish': U32 = 0, step': U32 = 1) =>
        start = start'
        finish = finish'
        step = step'

    be subscribe(s: Subscriber[U32]) =>
        s.on_subscribe(_Sub(s, start, finish, step))
        


class _Sub is Subscription
    let sub: Subscriber[U32]
    var state: U32

    let finish: U32
    let step: U32

    new iso create(sub': Subscriber[U32], start': U32, finish': U32, step': U32) => 
        sub = sub'
        state = start'
        finish = finish'
        step = step'

    fun ref request(n': U64) =>
        var n = n'
        while (state < finish) and (n > 0) do
            sub.on_next(state)
            state = state + step
            if state >= finish then sub.on_complete() end
            n = n - 1
        end

    fun ref cancel() => None