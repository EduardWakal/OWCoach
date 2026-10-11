import OWCoachKit
import SwiftData
import SwiftUI

struct VODListView: View {
    @Environment(\.content) private var content
    @Environment(\.modelContext) private var context
    @Query(sort: \VODReview.date, order: .reverse) private var reviews: [VODReview]
    @Query private var findings: [Finding]
    @State private var showLearnings = false
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if showLearnings {
                    LearningsView(findings: findings.map(\.record))
                } else if reviews.isEmpty {
                    ContentUnavailableView("Noch keine Reviews", systemImage: "play.rectangle", description: Text("Tippe auf +, um ein Replay zu besprechen."))
                } else {
                    List {
                        ForEach(reviews) { review in
                            NavigationLink(value: VODReviewRoute(key: review.key)) {
                                row(review)
                            }
                        }
                        .onDelete { offsets in
                            offsets.map { reviews[$0] }.forEach { FocusActions.deleteReview($0, in: context) }
                        }
                    }
                }
            }
            .safeAreaInset(edge: .top) {
                Picker("Ansicht", selection: $showLearnings) {
                    Text("Reviews").tag(false)
                    Text("Learnings").tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
            .navigationTitle("VOD")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Neues Review", systemImage: "plus") { addReview() }
                }
            }
            .navigationDestination(for: VODReviewRoute.self) { route in
                VODDetailView(reviewKey: route.key)
            }
            .navigationDestination(for: CardRoute.self) { CardDetailView(cardID: $0.id) }
        }
    }

    private func row(_ review: VODReview) -> some View {
        let count = findings.filter { $0.reviewKey == review.key }.count
        return HStack(spacing: 12) {
            HeroIcon(heroID: review.heroID, size: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(content.map(review.mapID)?.name ?? (review.mapID.isEmpty ? "Ohne Map" : review.mapID)).font(.headline)
                Text([review.date.formatted(date: .abbreviated, time: .omitted), review.replayCode.isEmpty ? nil : review.replayCode].compactMap { $0 }.joined(separator: " · "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(count)").font(.subheadline.bold()).monospacedDigit()
            Image(systemName: "text.bubble").foregroundStyle(.secondary)
        }
        .frame(minHeight: 52)
    }

    private func addReview() {
        let review = VODReview()
        context.insert(review)
        try? context.save()
        showLearnings = false
        path.append(VODReviewRoute(key: review.key))
    }
}

struct VODReviewRoute: Hashable {
    let key: String
}
