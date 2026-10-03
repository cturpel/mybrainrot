import SwiftUI

struct InsightsView: View {
    @EnvironmentObject var store: AppStore

    private var maxMinutes: Int { max(store.brain.usage.map(\.minutes).max() ?? 1, 1) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Last 7 days").font(.headline)
                        HStack(alignment: .bottom, spacing: 12) {
                            ForEach(store.brain.usage.suffix(7)) { d in
                                VStack(spacing: 6) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(d.minutes > store.brain.dailyGoalMinutes ? .red : .pink)
                                        .frame(height: barHeight(d))
                                    Text(Self.dayLabel(d.day))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .frame(height: 160, alignment: .bottom)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(.gray.opacity(0.15)))

                    VStack(spacing: 10) {
                        InsightRow(symbol: "clock.fill", label: "Weekly average", value: "\(store.weeklyAverage) min/day")
                        if let top = store.topBrainrotApp {
                            InsightRow(symbol: "exclamationmark.triangle.fill", label: "Top brainrot app", value: top.name)
                        }
                        InsightRow(symbol: "timer", label: "Focus sessions", value: "\(store.brain.focusSessions.count) total")
                    }
                    .padding(.horizontal)

                    Text("Bars over your goal turn red — that's the rot setting in.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .navigationTitle("Insights")
        }
    }

    private func barHeight(_ d: DailyUsage) -> CGFloat {
        CGFloat(d.minutes) / CGFloat(maxMinutes) * 130
    }

    static func dayLabel(_ day: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f.string(from: day)
    }
}

struct InsightRow: View {
    let symbol: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: symbol).foregroundStyle(.pink).frame(width: 28)
            Text(label)
            Spacer()
            Text(value).bold()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
}

#Preview {
    InsightsView().environmentObject(AppStore())
}
