import SwiftUI

// This NSViewRepresentable is the key to fixing the freeze.
// It hosts a standard AppKit NSTextField.
// Instead of SwiftUI redrawing the view, we imperatively update the text field's value.
// This is very efficient and does not cause the MenuBarExtra to redraw its structure.
struct MenuBarLabelView: NSViewRepresentable {
    // The text to display, provided by the BreakTimer.
    var text: String

    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField(labelWithString: text)
        textField.font = .monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        return textField
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        // This is the imperative update. We just set the string value directly.
        nsView.stringValue = text
    }
}
