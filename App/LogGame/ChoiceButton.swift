import SwiftUI

struct ChoiceButton<Label: View>: View {
    let selected: Bool
    var tint: Color = Theme.accent
    let action: () -> Void
    @ViewBuilder let label: () -> Label

    var body: some View {
        Button(action: action) {
            label()
                .frame(maxWidth: .infinity, minHeight: 56)
                .padding(.horizontal, 12)
                .contentShape(.rect(cornerRadius: 18))
        }
        .buttonStyle(.plain)
        .glassEffect(selected ? .regular.tint(tint.opacity(0.55)).interactive() : .regular.interactive(), in: .rect(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18).strokeBorder(selected ? tint : .clear, lineWidth: 2)
        }
    }
}
