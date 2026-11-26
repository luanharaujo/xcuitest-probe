import SwiftUI

@main
struct ProbeApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
    }
}

struct ContentView: View {
    @State private var tapped = false

    var body: some View {
        VStack(spacing: 24) {
            Button("Tap me") { tapped = true }
                .accessibilityIdentifier("tapButton")
            Text(tapped ? "Tapped" : "Waiting")
                .accessibilityIdentifier("status")
        }
    }
}
