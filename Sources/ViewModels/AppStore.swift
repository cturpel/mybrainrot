import Foundation
import SwiftUI

extension Notification.Name {
    static let requestAuthorization = Notification.Name("requestAuthorization")
}

@MainActor
final class AppStore: ObservableObject {
    @Published var brain = BrainState()

    private let saveKey = "brainrot.state.v1"
    private let engine = FocusEngine()

    // MARK: - Persistence

    init() {
        load()
        seedSampleUsage()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: saveKey) else { return }
        if let s = try? JSONDecoder().decode(BrainState.self, from: data) {
            brain = s
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(brain) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    private func seedSampleUsage() {
        guard brain.usage.isEmpty else { return }
        var usage: [DailyUsage] = []
        let cal = Calendar.current
        for offset in stride(from: 6, through: 0, by: -1) {
            let day = cal.date(byAdding: .day, value: -offset, to: cal.startOfDayFor(Date()))!
            let minutes = [210, 260, 180, 300, 150, 240, 0][offset]
            usage.append(DailyUsage(day: day, minutes: minutes))
        }
        brain.usage = usage
        // today = 0, will be replaced by live data
    }

    // MARK: - Screen Time (simulated)

    /// MARK: Integration point — replace with DeviceActivity / FamilyControls.
    /// Real blocking requires Apple's Family Controls entitlement, which must be
    /// requested from Apple at https://developer.apple.com/contact/request/family-controls/
    func refreshUsage() {
        let cal = Calendar.current
        let today = cal.startOfDayFor(Date())
        if brain.usage.last?.day != today {
            brain.usage.append(DailyUsage(day: today, minutes: brain.minutesUsedToday))
        }
    }

    func logMinutes(_ minutes: Int) {
        let cal = Calendar.current
        let today = cal.startOfDayFor(Date())
        if let idx = brain.usage.firstIndex(where: { $0.day == today }) {
            brain.usage[idx].minutes += minutes
        } else {
            brain.usage.append(DailyUsage(day: today, minutes: minutes))
        }
        save()
    }

    // MARK: - Blocking

    func toggleBlocked(_ app: BlockedApp) {
        if let idx = brain.blockedApps.firstIndex(where: { $0.id == app.id }) {
            brain.blockedApps[idx].isBlocked.toggle()
            save()
        }
    }

    func setLimit(_ minutes: Int, for app: BlockedApp) {
        if let idx = brain.blockedApps.firstIndex(where: { $0.id == app.id }) {
            brain.blockedApps[idx].dailyLimitMinutes = minutes
            save()
        }
    }

    // MARK: - Schedules

    func toggleSchedule(_ s: ScheduleBlock) {
        if let idx = brain.schedules.firstIndex(where: { $0.id == s.id }) {
            brain.schedules[idx].isEnabled.toggle()
            save()
        }
    }

    func addSchedule(name: String, kind: ScheduleBlock.Kind, start: Date, end: Date) {
        brain.schedules.append(ScheduleBlock(name: name, kind: kind, start: start, end: end))
        save()
    }

    func deleteSchedule(_ s: ScheduleBlock) {
        brain.schedules.removeAll { $0.id == s.id }
        save()
    }

    // MARK: - Focus

    func completeFocusSession(minutes: Int, tag: String) {
        brain.focusSessions.append(FocusSession(startedAt: Date(), minutes: minutes, tag: tag))
        save()
    }

    // MARK: - Goal

    func setDailyGoal(_ minutes: Int) {
        brain.dailyGoalMinutes = minutes
        save()
    }

    // MARK: - Insights

    var weeklyAverage: Int {
        let last7 = brain.usage.suffix(7)
        guard !last7.isEmpty else { return 0 }
        return last7.map(\.minutes).reduce(0, +) / last7.count
    }

    var topBrainrotApp: BlockedApp? {
        brain.blockedApps.max { $0.dailyLimitMinutes < $1.dailyLimitMinutes }
    }
}
