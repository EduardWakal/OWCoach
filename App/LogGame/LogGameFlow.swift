import OWCoachKit
import SwiftData
import SwiftUI

struct LogGameFlow: View {
    @Environment(\.content) private var content
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    let onSaved: () -> Void

    @State private var draft = GameDraft(defaultRole: nil)
    @State private var pool: [String] = []
    @State private var focusCard: Card?
    @State private var tick = 0
    @State private var prepared = false
    @State private var saving = false
    @State private var pendingStep: Task<Void, Never>?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                progress
                ScrollView {
                    stepView
                        .id(draft.step)
                        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                }
                .scrollDismissesKeyboard(.immediately)
                navigationButtons
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen", role: .cancel) { dismiss() }
                }
            }
            .gesture(swipe)
            .sensoryFeedback(.selection, trigger: tick)
            .animation(.snappy(duration: 0.25), value: draft.step)
        }
        .onAppear(perform: prepare)
    }

    private var title: String {
        switch draft.step {
        case .role: "Rolle"
        case .hero: "Held"
        case .map: "Map"
        case .result: "Ergebnis"
        case .focus: "Fokus"
        case .death: "Tode"
        case .tilt: "Tilt"
        }
    }

    private var progress: some View {
        HStack(spacing: 6) {
            ForEach(GameDraft.Step.allCases, id: \.rawValue) { step in
                Capsule()
                    .fill(step.rawValue <= draft.step.rawValue ? Theme.accent : Color.secondary.opacity(0.3))
                    .frame(height: 5)
            }
        }
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private var stepView: some View {
        switch draft.step {
        case .role:
            RoleStep(selected: draft.role) { role in pick { draft.choose(role: role) } }
        case .hero:
            HeroStep(role: draft.role, pool: pool, selected: draft.heroID) { id in pick { draft.choose(heroID: id) } }
        case .map:
            MapStep(selected: draft.mapID) { id in pick { draft.choose(mapID: id) } }
        case .result:
            ResultStep(selected: draft.result) { result in pick { draft.choose(result: result) } }
        case .focus:
            FocusStep(card: focusCard, selected: draft.focus) { value in pick { draft.choose(focus: value) } }
        case .death:
            DeathStep(selected: draft.deathCause) { cause in pick { draft.choose(deathCause: cause) } }
        case .tilt:
            TiltStep(selected: draft.tilt) { value in
                tick += 1
                draft.choose(tilt: value)
                save()
            }
        }
    }

    private var navigationButtons: some View {
        HStack(spacing: 12) {
            Button {
                move { draft.goBack() }
            } label: {
                Label("Zurück", systemImage: "chevron.left").frame(maxWidth: .infinity, minHeight: 52)
            }
            .buttonStyle(.glass)
            .disabled(!draft.canGoBack)

            Button {
                move { draft.advance() }
            } label: {
                HStack(spacing: 6) { Text("Weiter"); Image(systemName: "chevron.right") }.frame(maxWidth: .infinity, minHeight: 52)
            }
            .buttonStyle(.glassProminent)
            .disabled(!draft.canAdvance)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    private var swipe: some Gesture {
        DragGesture(minimumDistance: 40).onEnded { value in
            guard abs(value.translation.width) > abs(value.translation.height) else { return }
            move { if value.translation.width < 0 { draft.advance() } else { draft.goBack() } }
        }
    }

    private func move(_ change: () -> Void) {
        pendingStep?.cancel()
        pendingStep = nil
        change()
    }

    private func pick(_ change: () -> Void) {
        tick += 1
        pendingStep?.cancel()
        let before = draft.step
        change()
        guard draft.step != before else { return }
        let target = draft.step
        draft.step = before
        pendingStep = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(150))
            guard !Task.isCancelled, draft.step == before else { return }
            draft.step = target
        }
    }

    private func prepare() {
        guard !prepared else { return }
        prepared = true
        let settings = AppSettings.current(in: context)
        let focus = FocusPlan.current(in: context)
        draft = GameDraft(defaultRole: settings.defaultRole)
        pool = settings.poolHeroIDs
        focusCard = focus.activeCardID.flatMap(content.card)
    }

    private func save() {
        guard !saving else { return }
        saving = true
        let focus = FocusPlan.current(in: context)
        guard let record = draft.record(date: .now, focusCardID: focus.activeCardID) else {
            saving = false
            return
        }
        context.insert(GameEntry(record: record))
        try? context.save()
        onSaved()
        dismiss()
    }
}
