import Foundation

/// Retries a failed capture start until it succeeds. It never gives up: whatever blocks
/// capture (lid closed and every display asleep, replayd restarting) can last for hours,
/// and a loop that stops trying leaves capture off until the user notices.
@MainActor
final class CaptureRetryLoop {
    /// Seconds to wait before each attempt; the last one repeats.
    nonisolated static let defaultDelays: [Double] = [3, 10, 30, 60, 120]

    private let delays: [Double]
    private let sleep: @MainActor (Double) async -> Void
    private var task: Task<Void, Never>?

    var isActive: Bool { task != nil }

    init(delays: [Double] = CaptureRetryLoop.defaultDelays,
         sleep: @escaping @MainActor (Double) async -> Void = { seconds in
             try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
         }) {
        precondition(!delays.isEmpty && delays.allSatisfy { $0.isFinite && $0 >= 0 })
        self.delays = delays
        self.sleep = sleep
    }

    /// Starts retrying from the first delay, replacing a retry that is already underway.
    /// `attempt` returns true when nothing is left to retry.
    func start(_ attempt: @escaping @MainActor () async -> Bool) {
        task?.cancel()
        task = Task {
            var index = 0
            while true {
                await sleep(delays[min(index, delays.count - 1)])
                index += 1
                // Cancelled means stopped, or replaced by a newer loop that now owns `task`.
                guard !Task.isCancelled else { return }
                let done = await attempt()
                guard !Task.isCancelled else { return }
                if done {
                    task = nil
                    return
                }
            }
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
    }
}
