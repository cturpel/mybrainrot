import SwiftUI

struct RootView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "brain") }
            BlockerView()
                .tabItem { Label("Block", systemImage: "hand.raised.fill") }
            FocusView()
                .tabItem { Label("Focus", systemImage: "timer") }
            ScheduleView()
                .tabItem { Label("Schedule", systemImage: "clock.fill") }
            InsightsView()
                .tabItem { Label("Insights", systemImage: "chart.bar.fill") }
        }
        .tint(.pink)
    }
}

#Preview {
    RootView().environmentObject(AppStore())
}
