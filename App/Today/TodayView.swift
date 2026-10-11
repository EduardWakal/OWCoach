import OWCoachKit
import SwiftData
import SwiftUI

struct TodayView: View {
    @Environment(\.content) private var content
    @Environment(\.modelContext) private var context
    @Query(sort: \GameEntry.date) private var entries: [GameEntry]
    @Query private var progress: [CardProgress]
    @Query(sort: \AppSettings.createdAt) private var allSettings: [AppSettings]
    @Query(sort: \FocusPlan.createdAt) private var plans: [FocusPlan]

    @State private var showLog = false
    @State private var showFocusPicker = false
    @State private var showWeekHeroes = false
    @State private var showSettings = false
    @State private var savedToast = false
    @State private var weekHeroDraft: [String] = []

    private var weekHeroes: [String] { plans.first?.weekHeroIDs ?? [] }
    private var activeCardID: String? { plans.first?.activeCardID }

    var body: some View {
        let records = entries.map(\.record)
        let mastered = Set(progress.filter { $0.masteredAt != nil }.map(\.cardID))
        let settings = allSettings.first
        let suggestion = SuggestionEngine.suggestion(for: SuggestionInput(games: records, activeCardID: activeCardID, masteredCardIDs: mastered, dismissedAtGameCount: settings?.dismissed ?? [:]))
        let todayEntries = entries.filter { Calendar.current.isDateInToday($0.date) }.reversed()

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    WeekHeroesBar(heroIDs: weekHeroes) {
                        weekHeroDraft = weekHeroes
                        showWeekHeroes = true
                    }
                    if let suggestion {
                        SuggestionBanner(suggestion: suggestion, accept: { accept(suggestion) }, dismiss: { dismissSuggestion(suggestion, gameCount: records.count) })
                    }
                    FocusCardView(card: activeCardID.flatMap(content.card), role: focusRole(settings)) { showFocusPicker = true }
                    Button {
                        showLog = true
                    } label: {
                        Label("Game loggen", systemImage: "plus")
                            .font(.title3.bold())
                            .frame(maxWidth: .infinity, minHeight: 60)
                    }
                    .buttonStyle(.glassProminent)
                    StatTiles(games: records)
                    TodayGamesList(games: Array(todayEntries)) { entry in
                        context.delete(entry)
                        try? context.save()
                    }
                }
                .padding(16)
            }
            .navigationTitle("Heute")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Einstellungen", systemImage: "gearshape") { showSettings = true }
                }
            }
            .overlay(alignment: .top) {
                if savedToast {
                    Label("Gespeichert", systemImage: "checkmark.circle.fill")
                        .font(.subheadline.bold())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .glassEffect(.regular.tint(.green.opacity(0.4)), in: .capsule)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .sensoryFeedback(.success, trigger: savedToast) { _, new in new }
        }
        .onAppear(perform: load)
        .sheet(isPresented: $showLog) {
            LogGameFlow { showSavedToast() }
        }
        .sheet(isPresented: $showFocusPicker) {
            FocusPickerSheet(weekHeroIDs: weekHeroes, activeCardID: activeCardID, mastered: mastered) { FocusActions.setFocus($0, in: context) }
        }
        .sheet(isPresented: $showWeekHeroes, onDismiss: saveWeekHeroes) {
            WeekHeroesSheet(pool: settings?.poolHeroIDs ?? [], selection: $weekHeroDraft)
        }
        .sheet(isPresented: $showSettings, onDismiss: load) {
            SettingsView()
        }
    }

    private func focusRole(_ settings: AppSettings?) -> Role? {
        if let id = activeCardID, let hero = content.heroOwning(cardID: id) { return hero.role }
        return weekHeroes.first.flatMap(content.hero)?.role ?? settings?.defaultRole
    }

    private func load() {
        _ = AppSettings.current(in: context)
        _ = FocusPlan.current(in: context)
    }

    private func saveWeekHeroes() {
        FocusPlan.current(in: context).weekHeroIDs = weekHeroDraft
        try? context.save()
    }

    private func accept(_ suggestion: Suggestion) {
        switch suggestion {
        case .cardMastered(let id):
            FocusActions.markMastered(id, in: context)
            showFocusPicker = true
        case .switchFocus(_, let id):
            FocusActions.setFocus(id, in: context)
        case .moveOn:
            showFocusPicker = true
        }
    }

    private func dismissSuggestion(_ suggestion: Suggestion, gameCount: Int) {
        let settings = AppSettings.current(in: context)
        var dismissed = settings.dismissed
        dismissed[suggestion.key] = gameCount
        settings.dismissed = dismissed
        try? context.save()
    }

    private func showSavedToast() {
        withAnimation { savedToast = true }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.5))
            withAnimation { savedToast = false }
        }
    }
}
