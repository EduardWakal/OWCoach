import OWCoachKit
import SwiftUI

struct LearningsView: View {
    @Environment(\.content) private var content
    let findings: [FindingRecord]

    var body: some View {
        let groups = Learnings.grouped(findings)
        if groups.isEmpty {
            ContentUnavailableView("Noch keine Learnings", systemImage: "lightbulb", description: Text("Findings aus deinen Reviews landen hier, sortiert nach Karte."))
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ForEach(groups) { group in
                        VStack(alignment: .leading, spacing: 8) {
                            NavigationLink(value: CardRoute(id: group.cardID)) {
                                HStack {
                                    Text(content.card(group.cardID)?.title ?? group.cardID).font(.title3.bold())
                                    Text("· \(group.findings.count)").font(.title3).foregroundStyle(.secondary)
                                    Spacer()
                                    Image(systemName: "chevron.right").foregroundStyle(.tertiary)
                                }
                                .contentShape(.rect)
                            }
                            .buttonStyle(.plain)
                            ForEach(group.findings) { FindingRow(finding: $0) }
                        }
                    }
                }
                .padding(16)
            }
        }
    }
}
