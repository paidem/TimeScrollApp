import Foundation
import Testing
@testable import TimeScroll

struct TimelineDayRangeTests {
    @Test func daylightSavingDaysUseCalendarBounds() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Vilnius")!
        for (month, day, hours) in [(3, 29, 23), (10, 25, 25), (11, 17, 24)] {
            let date = calendar.date(from: DateComponents(year: 2026, month: month, day: day, hour: 12))!
            let range = TimelineDayRange.bounds(for: date, calendar: calendar)
            #expect(range.upperBound - range.lowerBound + 1 == Int64(hours * 3_600_000))
        }
    }

    @Test func emptySingleAndBoundaryCaptures() {
        let day: ClosedRange<Int64> = 0...86_399_999
        #expect(TimelineDayRange.activeHours(first: nil, last: nil, day: day) == day)
        #expect(TimelineDayRange.activeHours(first: 1, last: 1, day: day) == 0...3_600_000)
        #expect(TimelineDayRange.activeHours(first: 86_399_999, last: 86_399_999, day: day) == 82_800_000...86_400_000)
    }
}
