import Foundation

struct BlockedApp: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var symbol: String
    var dailyLimitMinutes: Int
    var isBlocked: Bool = false
}

struct ScheduleBlock: Identifiable, Codable, Hashable {
    enum Kind: String, Codable, CaseIterable, Hashable {
        case bedtime = "Bedtime"
        case morning = "Morning"
        case work = "Work"
        case custom = "Custom"

        var symbol: String {
            switch self {
            case .bedtime: return "moon.zzz.fill"
            case .morning: return "sunrise.fill"
            case .work: return "briefcase.fill"
            case .custom: return "person.fill"
            }
        }
    }

    var id: UUID = UUID()
    var name: String
    var kind: Kind
    var start: Date
    var end: Date
    var isEnabled: Bool = true

    var formattedRange: String {
        let f = DateFormatter()
        f.timeStyle = .short
        return "\(f.string(from: start)) – \(f.string(from: end))"
    }
}

struct FocusSession: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var startedAt: Date
    var minutes: Int
    var tag: String
}

struct DailyUsage: Identifiable, Codable, Hashable {
    var id: Date { day }
    var day: Date
    var minutes: Int
}

struct BrainState: Codable, Hashable {
    var dailyGoalMinutes: Int = 180

    var decayStage: Int {
        // 0 = pristine ... 4 = fully rotten
        let ratio = Double(brainrotScore)
        switch ratio {
        case ..<20: return 0
        case ..<40: return 1
        case ..<60: return 2
        case ..<80: return 3
        default: return 4
        }
    }

    var brainrotScore: Int { // percent of daily goal used
        min(100, Int((Double(minutesUsedToday) / Double(max(dailyGoalMinutes, 1))) * 100))
    }

    var minutesUsedToday: Int {
        usage.first { Calendar.current.isDateInToday($0.day) }?.minutes ?? 0
    }

    var usage: [DailyUsage] = []
    var blockedApps: [BlockedApp] = [
        BlockedApp(name: "Scrollr", symbol: "photo.stack.fill", dailyLimitMinutes: 30, isBlocked: true),
        BlockedApp(name: "Chatly", symbol: "message.fill", dailyLimitMinutes: 45),
        BlockedApp(name: "StreamTube", symbol: "play.rectangle.fill", dailyLimitMinutes: 60, isBlocked: true),
        BlockedApp(name: "Gamesly", symbol: "gamecontroller.fill", dailyLimitMinutes: 40),
        BlockedApp(name: "Shopperoo", symbol: "cart.fill", dailyLimitMinutes: 15),
    ]
    var schedules: [ScheduleBlock] = [
        ScheduleBlock(name: "Bedtime", kind: .bedtime,
                      start: Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date())!,
                      end: Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date())!),
    ]
    var focusSessions: [FocusSession] = []
    var streakDays: Int = 3
}
