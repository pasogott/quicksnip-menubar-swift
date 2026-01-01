import SwiftUI

struct SettingsWindowView: View {
    var body: some View {
        Form {
            Section("General") {
                Text("Settings will appear here")
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(width: 400, height: 200)
    }
}

#Preview {
    SettingsWindowView()
}
