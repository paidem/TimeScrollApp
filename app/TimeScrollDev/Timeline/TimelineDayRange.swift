import Foundation

/// Calendar-day bounds and the active-hour span used by the fitted day timeline.
enum TimelineDayRange {
    static func bounds(for date: Date, calendar: Calendar = .current) -> ClosedRange<Int64> {
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        return Int64(start.timeIntervalSince1970 * 1000)...(Int64(end.timeIntervalSince1970 * 1000) - 1)
    }

    static func activeHours(first: Int64?, last: Int64?, day: ClosedRange<Int64>) -> ClosedRange<Int64> {
        guard let first, let last else { return day }
        let hour: Int64 = 3_600_000
        let start = max(day.lowerBound, day.lowerBound + (first - day.lowerBound) / hour * hour)
        let end = min(day.upperBound + 1, day.lowerBound + ((last - day.lowerBound) / hour + 1) * hour)
        return start...max(start, end)
    }
}
