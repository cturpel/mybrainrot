import SwiftUI

struct FocusView: View {
    @EnvironmentObject var store: AppStore
    @State private var engine = FocusEngine()
    @State private var remainingSeconds = 25 * 60
    @State private var totalSeconds = 25 * 60
    @State private var isRunning = false
    @State private var tag = "Deep work"

    private let presets = [15, 25, 45, 60]

    var body: some View {
        NavigationStack {
            VStack(spacing: 28) {
                ZStack {
                    Circle()
                        .stroke(.gray.opacity(0.2), lineWidth: 12)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(.pink, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: progress)
                    Text(timeString)
                        .font(.system(size: 44, weight: .bold, design: .monospaced))
                }
                .frame(width: 220, height: 220)

                Picker("Tag", selection: $tag) {
                    ForEach(["Deep work", "Study", "Reading", "Chores"], id: \.self) { Text($0) }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                HStack(spacing: 12) {
                    ForEach(presets, id: \.self) { m in
                        Button("\(m)m") {
                            stop()
                            totalSeconds = m * 60
                            remainingSeconds = m * 60
                        }
                        .buttonStyle(.bordered)
                        .tint(remainingSeconds == m * 60 ? .pink : .secondary)
                    }
                }

                Button {
                    isRunning ? stop() : start()
                } label: {
                    Label(isRunning ? "Give up" : "Start focus", systemImage: isRunning ? "stop.fill" : "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                List(store.brain.focusSessions.suffix(5).reversed()) { s in
                    HStack {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.mint)
                        Text("\(s.minutes) min — \(s.tag)")
                        Spacer()
                        Text(s.startedAt, style: .date).font(.caption).foregroundStyle(.secondary)
                    }
                }
                .frame(maxHeight: 180)
                .listStyle(.inset)
                .overlay {
                    if store.brain.focusSessions.isEmpty {
                        Text("No sessions yet").foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .navigationTitle("Focus Timer")
        }
    }

    private var progress: CGFloat {
        totalSeconds == 0 ? 0 : CGFloat(totalSeconds - remainingSeconds) / CGFloat(totalSeconds)
    }

    private var timeString: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    private func start() {
        isRunning = true
        engine.start(seconds: remainingSeconds, onTick: { remaining in
            Task { @MainActor in remainingSeconds = remaining }
        }, onEnd: {
            Task { @MainActor in
                isRunning = false
                store.completeFocusSession(minutes: totalSeconds / 60, tag: tag)
                remainingSeconds = totalSeconds
            }
        })
    }

    private func stop() {
        isRunning = false
        engine.stop()
        remainingSeconds = totalSeconds
    }
}

#Preview {
    FocusView().environmentObject(AppStore())
}
