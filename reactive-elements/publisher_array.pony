use "reactive_streams"

actor ArrayPublisher[A: Any val] is Publisher[A]
    let content: Array[A] val

    new create(content': Array[A] val) =>
        content = content'

    be subscribe(s: Subscriber[A]) =>
        s.on_subscribe(_ArraySub[A](s, content))
        
class _ArraySub[A: Any val] is Subscription
    let sub: Subscriber[A]
    let content: Array[A] val
    var state: USize = 0

    new iso create(sub': Subscriber[A], content': Array[A] val) => 
        sub = sub'
        content = content'

    fun ref request(n': U64) =>
        var n = n'
        while (state < content.size()) and (n > 0) do
            try sub.on_next(content(state)?) end
            state = state + 1
            if state >= content.size() then sub.on_complete() end
            n = n - 1
        end

    fun ref cancel() => None
