import Foundation
import Testing
@testable import OWCoachKit

struct GameDraftTests {
    @Test func defaultRoleIsPreselectedButStepStaysOnRole() {
        let draft = GameDraft(defaultRole: .tank)
        #expect(draft.step == .role)
        #expect(draft.role == .tank)
        #expect(draft.canAdvance)
    }

    @Test func choosingAdvances() {
        var draft = GameDraft(defaultRole: nil)
        draft.choose(role: .damage)
        #expect(draft.step == .hero)
        draft.choose(heroID: "torbjorn")
        draft.choose(mapID: "busan")
        draft.choose(result: .win)
        draft.choose(focus: 4)
        draft.choose(deathCause: .open)
        #expect(draft.step == .tilt)
        draft.choose(tilt: 1)
        #expect(draft.step == .tilt)
    }

    @Test func changingRoleClearsHero() {
        var draft = GameDraft(defaultRole: .damage)
        draft.advance()
        draft.choose(heroID: "torbjorn")
        draft.goBack()
        draft.goBack()
        draft.choose(role: .tank)
        #expect(draft.heroID == nil)
        #expect(draft.step == .hero)
    }

    @Test func reselectingSameRoleKeepsHero() {
        var draft = GameDraft(defaultRole: .damage)
        draft.advance()
        draft.choose(heroID: "torbjorn")
        draft.goBack()
        draft.goBack()
        draft.choose(role: .damage)
        #expect(draft.heroID == "torbjorn")
    }

    @Test func heroStepWithEmptyPoolCannotAdvance() {
        var draft = GameDraft(defaultRole: .support)
        draft.advance()
        #expect(draft.step == .hero)
        #expect(!draft.canAdvance)
        draft.advance()
        #expect(draft.step == .hero)
    }

    @Test func backStopsAtFirstStep() {
        var draft = GameDraft(defaultRole: nil)
        #expect(!draft.canGoBack)
        draft.goBack()
        #expect(draft.step == .role)
    }

    @Test func recordOnlyWhenComplete() {
        var draft = GameDraft(defaultRole: .damage)
        let now = Date(timeIntervalSince1970: 1_000_000)
        #expect(draft.record(date: now, focusCardID: nil) == nil)
        draft.advance()
        draft.choose(heroID: "torbjorn")
        draft.choose(mapID: "busan")
        draft.choose(result: .loss)
        draft.choose(focus: 2)
        draft.choose(deathCause: .tooFar)
        draft.choose(tilt: 3)
        let record = draft.record(date: now, focusCardID: "cover")
        #expect(record == GameRecord(date: now, role: .damage, heroID: "torbjorn", mapID: "busan", result: .loss, focus: 2, focusCardID: "cover", deathCause: .tooFar, tilt: 3))
    }
}
