import SwiftUI

struct BrainAvatar: View {
    let stage: Int

    private var color: Color {
        switch stage {
        case 0: return .mint
        case 1: return .yellow
        case 2: return .orange
        case 3: return .red
        default: return .purple
        }
    }

    private var face: String {
        switch stage {
        case 0: return "😌"
        case 1: return "🙂"
        case 2: return "😵"
        case 3: return "🤪"
        default: return "💀"
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.25))
                .frame(width: 160, height: 160)
            Image(systemName: "brain.fill")
                .font(.system(size: 72))
                .foregroundStyle(color)
                .rotationEffect(.degrees(Double(stage) * 4))
            Text(face)
                .font(.system(size: 36))
                .offset(y: 26)
        }
        .animation(.spring(duration: 0.6), value: stage)
    }
}

struct HomeView: View {
    @EnvironmentObject var store: AppStore
    @State private var showingGoalSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    BrainAvatar(stage: store.brain.decayStage)

                    Text(stageLabel)
                        .font(.title2.bold())

                    ProgressView(value: Double(store.brain.brainrotScore), total: 100)
                        .progressViewStyle(.linear)
                        .padding(.horizontal, 32)

                    Text("\(store.brain.minutesUsedToday) min of \(store.brain.dailyGoalMinutes) min goal")
                        .foregroundStyle(.secondary)

                    HStack(spacing: 16) {
                        StatCard(title: "Streak", value: "\(store.brain.streakDays)d", symbol: "flame.fill")
                        StatCard(title: "Blocked", value: "\(store.brain.blockedApps.filter(\\.isBlocked).count)", symbol: "hand.raised.fill")
                        StatCard(title: "Focus today", value: "\(focusMinutesToday)m", symbol: "timer")
                    }
                    .padding(.horizontal)

                    Button("Adjust daily goal") { showingGoalSheet = true }
                        .buttonStyle(.bordered)

                    Text("Your brain rots 1 stage for every 20% of your daily goal you burn.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.vertical, 24)
            }
            .navigationTitle("Brainrot")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { store.refreshUsage() } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .sheet(isPresented: $showingGoalSheet) {
                GoalSheet().presentationDetents([.medium])
            }
        }
    }

    private var focusMinutesToday: Int {
        let cal = Calendar.current
        return store.brain.focusSessions
            .filter { cal.isDateInToday($0.startedAt) }
            .map(\.minutes).reduce(0, +)
    }

    private var stageLabel: String {
        switch store.brain.decayStage {
        case 0: return "Fresh brain. Go touch grass 🌱"
        case 1: return "Slight rot creeping in…"
        case 2: return "Half-rotten. Put it down."
        case 3: return "Critically rotten! 🚨"
        default: return "Fully brainrotted. F."
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let symbol: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .foregroundStyle(.pink)
            Text(value).font(.title3.bold())
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 16).fill(.gray.opacity(0.15)))
    }
}

struct GoalSheet: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var minutes = 180

    var body: some View {
        NavigationStack {
            Form {
                Stepper(value: $minutes, in: 30...600, step: 15) {
                    Text("\(minutes) minutes per day")
                }
            }
            .navigationTitle("Daily Goal")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.setDailyGoal(minutes)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView().environmentObject(AppStore())
}
