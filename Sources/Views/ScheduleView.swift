import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var store: AppStore
    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.brain.schedules) { s in
                    ToggleScheduleRow(schedule: s)
                }
                .onDelete { indexSet in
                    for i in indexSet { store.deleteSchedule(store.brain.schedules[i]) }
                }
            }
            .navigationTitle("Smart Schedules")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAddSheet = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddScheduleSheet()
                    .presentationDetents([.medium])
            }
        }
    }
}

struct ToggleScheduleRow: View {
    @EnvironmentObject var store: AppStore
    let schedule: ScheduleBlock

    var body: some View {
        HStack {
            Image(systemName: schedule.kind.symbol)
                .foregroundStyle(.pink)
                .frame(width: 32)
            VStack(alignment: .leading) {
                Text(schedule.name).bold()
                Text(schedule.formattedRange).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Toggle("", isOn: Binding(
                get: { schedule.isEnabled },
                set: { _ in store.toggleSchedule(schedule) }
            ))
            .labelsHidden()
        }
    }
}

struct AddScheduleSheet: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var kind: ScheduleBlock.Kind = .bedtime
    @State private var start = Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date())!
    @State private var end = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date())!

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                Picker("Type", selection: $kind) {
                    ForEach(ScheduleBlock.Kind.allCases, id: \.self) { Text($0.rawValue) }
                }
                DatePicker("Starts", selection: $start, displayedComponents: .hourAndMinute)
                DatePicker("Ends", selection: $end, displayedComponents: .hourAndMinute)
            }
            .navigationTitle("New Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        store.addSchedule(name: name.isEmpty ? kind.rawValue : name,
                                          kind: kind, start: start, end: end)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ScheduleView().environmentObject(AppStore())
}
