import OWCoachKit
import SwiftData
import SwiftUI

struct VODDetailView: View {
    @Environment(\.content) private var content
    @Environment(\.modelContext) private var context
    @Query private var reviews: [VODReview]
    @Query(sort: \Finding.date) private var allFindings: [Finding]
    @Query(sort: \GameEntry.date, order: .reverse) private var entries: [GameEntry]
    @State private var editing: Finding?
    @State private var showNewFinding = false
    let reviewKey: String

    init(reviewKey: String) {
        self.reviewKey = reviewKey
        _reviews = Query(filter: #Predicate<VODReview> { $0.key == reviewKey })
    }

    var body: some View {
        if let review = reviews.first {
            let findings = allFindings.filter { $0.reviewKey == reviewKey }
            Form {
                Section("Replay") {
                    TextField("Replay-Code", text: Bindable(review).replayCode)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                    Picker("Held", selection: Bindable(review).heroID) {
                        Text("–").tag("")
                        ForEach(content.heroes) { Text($0.name).tag($0.id) }
                    }
                    Picker("Map", selection: Bindable(review).mapID) {
                        Text("–").tag("")
                        ForEach(content.maps) { Text($0.name).tag($0.id) }
                    }
                    Menu {
                        ForEach(entries.prefix(10)) { entry in
                            Button("\(content.hero(entry.heroID)?.name ?? entry.heroID) · \(content.map(entry.mapID)?.name ?? entry.mapID) · \(entry.date.formatted(date: .abbreviated, time: .shortened))") {
                                review.heroID = entry.heroID
                                review.mapID = entry.mapID
                                review.date = entry.date
                                try? context.save()
                            }
                        }
                    } label: {
                        Label("Aus Game übernehmen", systemImage: "arrow.down.doc")
                    }
                    .disabled(entries.isEmpty)
                }

                Section("Findings") {
                    if findings.isEmpty {
                        Text("Was hast du gesehen? Ein Satz pro Moment.").foregroundStyle(.secondary)
                    }
                    ForEach(findings) { finding in
                        Button {
                            editing = finding
                        } label: {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: finding.starred ? "star.fill" : "text.bubble")
                                    .foregroundStyle(finding.starred ? Theme.accent : .secondary)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(finding.text)
                                    Text([finding.moment, content.card(finding.cardID)?.title ?? finding.cardID].compactMap { $0 }.joined(separator: " · "))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                            .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { offsets in
                        offsets.map { findings[$0] }.forEach(context.delete)
                        try? context.save()
                    }
                    Button {
                        showNewFinding = true
                    } label: {
                        Label("Finding hinzufügen", systemImage: "plus.circle.fill").frame(minHeight: 44)
                    }
                }
            }
            .navigationTitle(content.map(review.mapID)?.name ?? "Review")
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear { try? context.save() }
            .sheet(isPresented: $showNewFinding) {
                FindingEditor(heroID: review.heroID, finding: nil) { cardID, text, moment, starred in
                    context.insert(Finding(reviewKey: reviewKey, cardID: cardID, text: text, moment: moment, starred: starred))
                    try? context.save()
                }
            }
            .sheet(item: $editing) { finding in
                FindingEditor(heroID: review.heroID, finding: finding) { cardID, text, moment, starred in
                    finding.cardID = cardID
                    finding.text = text
                    finding.moment = moment
                    finding.starred = starred
                    try? context.save()
                }
            }
        } else {
            ContentUnavailableView("Review gelöscht", systemImage: "trash")
        }
    }
}
