import Foundation

@MainActor
protocol FileWatcherDelegate: AnyObject {
    func fileWatcherDidDetectChanges(_ watcher: FileWatcherService)
}

@MainActor
final class FileWatcherService {
    weak var delegate: FileWatcherDelegate?

    private let path: String
    private let debounceInterval: TimeInterval
    private nonisolated(unsafe) var eventStream: FSEventStreamRef?
    private var debounceTask: Task<Void, Never>?

    var isRunning: Bool { eventStream != nil }

    init(path: String, debounceInterval: TimeInterval = 0.5) {
        self.path = path
        self.debounceInterval = debounceInterval
    }

    convenience init(url: URL, debounceInterval: TimeInterval = 0.5) {
        self.init(path: url.path, debounceInterval: debounceInterval)
    }

    deinit {
        if let stream = eventStream {
            FSEventStreamStop(stream)
            FSEventStreamInvalidate(stream)
            FSEventStreamRelease(stream)
        }
    }

    func start() {
        guard eventStream == nil else { return }

        let pathsToWatch = [path] as CFArray

        var context = FSEventStreamContext(
            version: 0,
            info: Unmanaged.passUnretained(self).toOpaque(),
            retain: nil,
            release: nil,
            copyDescription: nil
        )

        let flags = UInt32(
            kFSEventStreamCreateFlagUseCFTypes |
            kFSEventStreamCreateFlagFileEvents |
            kFSEventStreamCreateFlagNoDefer
        )

        guard let stream = FSEventStreamCreate(
            nil,
            { _, clientCallBackInfo, _, _, _, _ in
                guard let info = clientCallBackInfo else { return }
                let watcher = Unmanaged<FileWatcherService>.fromOpaque(info).takeUnretainedValue()
                Task { @MainActor in
                    watcher.handleEvent()
                }
            },
            &context,
            pathsToWatch,
            FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
            0.1,
            flags
        ) else {
            return
        }

        eventStream = stream
        FSEventStreamSetDispatchQueue(stream, DispatchQueue.main)
        FSEventStreamStart(stream)
    }

    func stop() {
        guard let stream = eventStream else { return }

        debounceTask?.cancel()
        debounceTask = nil

        FSEventStreamStop(stream)
        FSEventStreamInvalidate(stream)
        FSEventStreamRelease(stream)
        eventStream = nil
    }

    private func handleEvent() {
        debounceTask?.cancel()

        debounceTask = Task {
            try? await Task.sleep(for: .milliseconds(Int(debounceInterval * 1000)))
            guard !Task.isCancelled else { return }
            delegate?.fileWatcherDidDetectChanges(self)
        }
    }
}
