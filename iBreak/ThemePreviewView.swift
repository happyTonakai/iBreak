import SwiftUI

struct ThemePreviewView: View {
    let theme: BreakTheme

    var body: some View {
        ZStack {
            theme.backgroundColor
                .cornerRadius(8)
            VStack {
                Text("Theme Preview")
                    .foregroundColor(theme.textColor)
                Text("00:30")
                    .font(.system(.title, design: .monospaced).bold())
                    .foregroundColor(theme.textColor)
            }
        }
        .frame(height: 100)
        .padding(.horizontal)
    }
}
