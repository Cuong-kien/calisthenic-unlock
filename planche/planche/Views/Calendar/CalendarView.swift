import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var displayedMonth: Date = Calendar.current.startOfMonth(for: Date())

    private var progressManager: ProgressManager {
        ProgressManager(modelContext: modelContext)
    }

    private var trainingDates: Set<DateComponents> {
        progressManager.trainingDates()
    }

    private var calendar: Calendar { Calendar.current }

    private var monthTitle: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMMM yyyy"
        return fmt.string(from: displayedMonth)
    }

    private var daysInMonth: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: displayedMonth) else { return [] }
        let firstWeekday = calendar.component(.weekday, from: displayedMonth)
        // Adjust so week starts on Monday (weekday 2 = Mon = offset 0)
        let offset = (firstWeekday - 2 + 7) % 7
        var days: [Date?] = Array(repeating: nil, count: offset)
        for day in range {
            var comps = calendar.dateComponents([.year, .month], from: displayedMonth)
            comps.day = day
            if let date = calendar.date(from: comps) {
                days.append(date)
            }
        }
        return days
    }

    private let weekdayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    private func hasTrained(on date: Date) -> Bool {
        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        return trainingDates.contains(comps)
    }

    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    private func prevMonth() {
        if let d = calendar.date(byAdding: .month, value: -1, to: displayedMonth) {
            displayedMonth = calendar.startOfMonth(for: d)
        }
    }

    private func nextMonth() {
        if let d = calendar.date(byAdding: .month, value: 1, to: displayedMonth) {
            displayedMonth = calendar.startOfMonth(for: d)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Month navigation header
                HStack {
                    Button { prevMonth() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.primary)
                            .padding(8)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }

                    Spacer()

                    Text(monthTitle)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)

                    Spacer()

                    Button { nextMonth() } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.primary)
                            .padding(8)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                // Weekday labels
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                    ForEach(weekdayLabels, id: \.self) { label in
                        Text(label)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 20)

                // Day grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                    ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, dateOpt in
                        if let date = dateOpt {
                            let trained = hasTrained(on: date)
                            let today = isToday(date)
                            let dayNum = calendar.component(.day, from: date)

                            VStack(spacing: 4) {
                                ZStack {
                                    if trained {
                                        Circle()
                                            .fill(Color.blue)
                                            .frame(width: 36, height: 36)
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundStyle(.white)
                                    } else if today {
                                        Circle()
                                            .strokeBorder(Color.blue, lineWidth: 2)
                                            .frame(width: 36, height: 36)
                                        Text("\(dayNum)")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundStyle(.blue)
                                    } else {
                                        Text("\(dayNum)")
                                            .font(.system(size: 14))
                                            .foregroundStyle(.primary)
                                            .frame(width: 36, height: 36)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            Color.clear.frame(height: 36)
                        }
                    }
                }
                .padding(.horizontal, 20)

                // Legend
                HStack(spacing: 20) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 12, height: 12)
                        Text("Trained")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.secondary)
                    }
                    HStack(spacing: 6) {
                        Circle()
                            .strokeBorder(Color.blue, lineWidth: 1.5)
                            .frame(width: 12, height: 12)
                        Text("Today")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.secondary)
                    }
                }
                .padding(.top, 4)
            }
        }
        .background(Color(.systemBackground))
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Calendar extension

private extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let comps = dateComponents([.year, .month], from: date)
        return self.date(from: comps) ?? date
    }
}
