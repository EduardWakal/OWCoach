import Charts
import OWCoachKit
import SwiftData
import SwiftUI

struct StatsView: View {
    @Environment(\.content) private var content
    @Query(sort: \GameEntry.date) private var entries: [GameEntry]
    @Query(sort: \FocusPlan.createdAt) private var plans: [FocusPlan]
    @Query private var progress: [CardProgress]
    @State private var range: StatsRange = .month
    @State private var selectedWinDay: Date?
    @State private var selectedFocusDay: Date?

    var body: some View {
        let all = entries.map(\.record)
        let games = range.filter(all, now: .now)

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Picker("Zeitraum", selection: $range) {
                        ForEach(StatsRange.allCases) { Text($0.label).tag($0) }
                    }
                    .pickerStyle(.segmented)

                    cardsPanel(all: all)

                    if games.isEmpty {
                        ContentUnavailableView("Keine Games in diesem Zeitraum", systemImage: "chart.bar", description: Text("Logge ein paar Games, dann siehst du hier deinen Verlauf."))
                    } else {
                        lineChart(title: "Winrate pro Spieltag", points: Stats.dailyWinRate(games), domain: 0...1, selection: $selectedWinDay) { "\(Int(($0 * 100).rounded())) %" }
                        lineChart(title: "Fokus Ø pro Spieltag", points: Stats.dailyFocus(games), domain: 1...5, selection: $selectedFocusDay) { $0.formatted(.number.precision(.fractionLength(1))) }
                        causesChart(games)
                        groupList(title: "Pro Held", stats: Stats.byHero(games)) { id in
                            HStack(spacing: 10) {
                                HeroIcon(heroID: id, size: 32)
                                Text(content.hero(id)?.name ?? id)
                            }
                        }
                        groupList(title: "Pro Map", stats: Stats.byMap(games)) { id in
                            HStack(spacing: 10) {
                                MapThumb(mapID: id, width: 48)
                                Text(content.map(id)?.name ?? id).lineLimit(1)
                            }
                        }
                    }
                }
                .padding(16)
            }
            .navigationTitle("Stats")
        }
    }

    private func cardsPanel(all: [GameRecord]) -> some View {
        let masteredCount = Set(progress.filter { $0.masteredAt != nil }.map(\.cardID)).count
        let active = plans.first?.activeCardID
        let since = active.flatMap { Stats.firstUse(of: $0, in: all) }
        return HStack(spacing: 10) {
            VStack(spacing: 4) {
                Text("\(masteredCount)").font(.title2.bold()).monospacedDigit()
                Text("Karten sitzen").font(.caption2).foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, minHeight: 72)
            .glassEffect(.regular, in: .rect(cornerRadius: 18))
            VStack(spacing: 4) {
                Text(active.flatMap(content.card)?.title ?? "–").font(.headline).lineLimit(1).minimumScaleFactor(0.7)
                Text(since.map { "Fokus seit \($0.formatted(date: .abbreviated, time: .omitted))" } ?? "Fokus").font(.caption2).foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, minHeight: 72)
            .padding(.horizontal, 8)
            .glassEffect(.regular, in: .rect(cornerRadius: 18))
        }
    }

    private func lineChart(title: String, points: [DayValue], domain: ClosedRange<Double>, selection: Binding<Date?>, format: @escaping (Double) -> String) -> some View {
        let selected = selection.wrappedValue.flatMap { day in points.min { abs($0.day.timeIntervalSince(day)) < abs($1.day.timeIntervalSince(day)) } }
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title).font(.headline)
                Spacer()
                if let selected {
                    Text("\(selected.day.formatted(date: .abbreviated, time: .omitted)): \(format(selected.value))")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
            }
            Chart {
                ForEach(points, id: \.day) { point in
                    LineMark(x: .value("Tag", point.day, unit: .day), y: .value(title, point.value))
                        .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                        .foregroundStyle(Theme.accent)
                    PointMark(x: .value("Tag", point.day, unit: .day), y: .value(title, point.value))
                        .symbol {
                            Circle().fill(Theme.accent).frame(width: 8, height: 8).overlay(Circle().stroke(Color(.systemBackground), lineWidth: 2))
                        }
                }
                if let selected {
                    RuleMark(x: .value("Tag", selected.day, unit: .day))
                        .foregroundStyle(.secondary.opacity(0.4))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                }
            }
            .chartYScale(domain: domain)
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisValueLabel { Text(value.as(Double.self).map(format) ?? "") }
                }
            }
            .chartXSelection(value: selection)
            .frame(height: 160)
        }
        .glassPanel()
    }

    private func causesChart(_ games: [GameRecord]) -> some View {
        let weeks = Stats.weeklyCauses(games)
        return VStack(alignment: .leading, spacing: 10) {
            Text("Todesursachen pro Woche").font(.headline)
            if weeks.isEmpty {
                Text("Kaum gestorben – nichts zu zeigen.").font(.subheadline).foregroundStyle(.secondary)
            } else {
            Chart(weeks, id: \.self) { item in
                BarMark(x: .value("Woche", item.weekStart, unit: .weekOfYear), y: .value("Games", item.count))
                    .foregroundStyle(by: .value("Ursache", item.cause.label))
                    .cornerRadius(4)
            }
            .chartForegroundStyleScale(domain: CauseColors.ordered.map(\.label), range: CauseColors.ordered.map(CauseColors.color))
            .chartLegend(position: .bottom, alignment: .leading)
            .frame(height: 200)
            }
        }
        .glassPanel()
    }

    private func groupList<RowLabel: View>(title: String, stats: [GroupStat], @ViewBuilder label: @escaping (String) -> RowLabel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            ForEach(stats.prefix(8)) { stat in
                HStack {
                    label(stat.id)
                    Spacer()
                    Text("\(stat.games) G").font(.caption).foregroundStyle(.secondary).monospacedDigit()
                    Text("\(Int((stat.winRate * 100).rounded())) %").font(.subheadline.bold()).monospacedDigit().frame(width: 52, alignment: .trailing)
                    Text("F \(stat.focusAverage.formatted(.number.precision(.fractionLength(1))))").font(.caption).monospacedDigit().frame(width: 40, alignment: .trailing)
                }
                .frame(minHeight: 44)
            }
        }
        .glassPanel()
    }
}
