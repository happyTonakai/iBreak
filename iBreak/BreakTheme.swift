import SwiftUI

struct BreakTheme: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let backgroundColor: Color
    let textColor: Color

    static let allThemes: [BreakTheme] = [
        .init(name: "Classic Black", backgroundColor: .black, textColor: .white),
        .init(name: "Deep Blue", backgroundColor: .blue.opacity(0.8), textColor: .white),
        .init(name: "Forest Green", backgroundColor: .green.opacity(0.8), textColor: .white),
        .init(name: "Charcoal", backgroundColor: Color(red: 0.2, green: 0.2, blue: 0.2), textColor: .white)
    ]

    static func theme(withName name: String) -> BreakTheme {
        return allThemes.first { $0.name == name } ?? allThemes[0]
    }
}
