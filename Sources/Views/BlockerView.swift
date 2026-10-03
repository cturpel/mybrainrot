import SwiftUI

struct BlockerView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        NavigationStack {
            List {
                Section("Block brainrot apps") {
                    ForEach(store.brain.blockedApps) { app in
                        ToggleBlockRow(app: app)
                    }
                }
                Section {
                    Text("Blocking is enforced on-device. Real system-wide blocking requires Apple's Family Controls entitlement.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("App Blocker")
        }
    }
}

struct ToggleBlockRow: View {
    @EnvironmentObject var store: AppStore
    let app: BlockedApp
    @State private var showingLimitSheet = false

    var body: some View {
        HStack {
            Image(systemName: app.symbol)
                .font(.title3)
                .frame(width: 36, height: 36)
                .background(RoundedRectangle(cornerRadius: 8).fill(.gray.opacity(0.2)))

            VStack(alignment: .leading, spacing: 2) {
                Text(app.name).bold()
                Text("Limit: \(app.dailyLimitMinutes) min/day")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { app.isBlocked },
                set: { _ in store.toggleBlocked(app) }
            ))
            .labelsHidden()
        }
        .contentShape(Rectangle())
        .onTapGesture { showingLimitSheet = true }
        .sheet(isPresented: $showingLimitSheet) {
            LimitSheet(app: app).presentationDetents([.medium])
        }
    }
}

struct LimitSheet: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    let app: BlockedApp
    @State private var minutes = 30

    var body: some View {
        NavigationStack {
            Form {
                Stepper(value: $minutes, in: 5...480, step: 5) {
                    Text("Daily limit: \(minutes) min")
                }
            }
            .navigationTitle("Limit — \(app.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.setLimit(minutes, for: app)
                        dismiss()
                    }
                }
            }
        }
        .onAppear { minutes = app.dailyLimitMinutes }
    }
}

#Preview {
    BlockerView().environmentObject(AppStore())
}
