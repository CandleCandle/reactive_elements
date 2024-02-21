use "reactive_streams"
use "files"

class val FilePublisherError is (ReactiveError & Stringable)
    let err: FileErrNo
    new val create(err': FileErrNo) =>
        err = err'

    fun box string(): String iso^ =>
        recover iso String.create().>append("err") end

actor FilePublisher is ManagedPublisher[Array[U8] val]
    let _sub_manager: SubscriberManager[Array[U8] val]
    let _path: FilePath
    let _max_bytes: USize
    var _file: (None | File) = None

    new create(path: FilePath, max_bytes: USize = 1024) =>
        _sub_manager = Broadcast[Array[U8] val](this)
        _path = path
        _max_bytes = max_bytes

    fun ref subscriber_manager(): SubscriberManager[Array[U8] val] =>
        _sub_manager

    be subscribe(s: Subscriber[Array[U8] val]) =>
        subscriber_manager().on_subscribe(s)

        match OpenFile(_path)
        | let file: File => _file = file
        | let err: FileErrNo => subscriber_manager().on_error(FilePublisherError(err))
        end

    be on_request(s: Subscriber[Array[U8] val], n: U64) =>
        """
        A ManagedPublisher must respond by calling SubscriberManager._on_request.
        """
        subscriber_manager().on_request(s, n)

        match _file
        | let file: File =>
            var count = n
            while (file.errno() is FileOK) and (count > 0) do
                let data = file.read(_max_bytes)
                if (data.size() > 0) then subscriber_manager().publish(consume data) end
                count = count - 1
            end
            if (not (file.errno() is FileOK)) then
                subscriber_manager().on_complete()
                _file = file.dispose()
            end
        end
