import SwiftUI

struct TrainingCalendar: View {
    let month: Date
    let completed: [Date: SessionKind]
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    var body: some View {
        VStack(spacing: 6) {
            LazyVGrid(columns: columns) { ForEach(["一", "二", "三", "四", "五", "六", "日"], id: \.self) { Text($0).font(.caption2).foregroundStyle(.secondary) } }
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(Array(days.enumerated()), id: \.offset) { _, date in
                    if let date { dayCell(date) } else { Color.clear.frame(height: 32) }
                }
            }
        }
    }

    private var days: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: month), let first = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else { return [] }
        let weekday = (calendar.component(.weekday, from: first) + 5) % 7
        return Array(repeating: nil, count: weekday) + range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: first) }
    }

    @ViewBuilder private func dayCell(_ date: Date) -> some View {
        let session = completed[calendar.startOfDay(for: date)]
        VStack(spacing: 2) {
            Text("\(calendar.component(.day, from: date))")
                .font(.caption)
                .frame(width: 32, height: 32, alignment: .center)
                .background(calendar.isDateInToday(date) ? Color.mint.opacity(0.55) : .clear, in: Circle())
            if let session { Text(session == .strengthA ? "A" : session == .strengthB ? "B" : session == .runWalk ? "跑" : "修").font(.caption2.bold()).foregroundStyle(color(for: session)) } else { Color.clear.frame(height: 10) }
        }
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .top)
    }

    private func color(for session: SessionKind) -> Color { switch session { case .strengthA: .orange; case .strengthB: .green; case .runWalk: .blue; case .recovery: .brown } }
}
