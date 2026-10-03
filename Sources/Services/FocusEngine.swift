import Foundation

struct FocusEngine {
    struct Tick: Equatable {
        var remainingSeconds: Int
        var isRunning: Bool = false
    }

    private var timer: Timer?

    mutating func start(seconds: Int, onTick: @escaping (Int) -> Void, onEnd: @escaping () -> Void) {
        var remaining = seconds
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            remaining -= 1
            if remaining <= 0 {
                t.invalidate()
                onTick(0)
                onEnd()
            } else {
                onTick(remaining)
            }
        }
    }

    mutating func stop() {
        timer?.invalidate()
        timer = nil
    }
}
