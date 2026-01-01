import SwiftUI

struct MenuBarContentView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("QuickSnip")
                .font(.headline)

            Text("Snippet manager")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .padding()
        .frame(width: 280)
    }
}

#Preview {
    MenuBarContentView()
}
