//
//  CaptureRetryLoopTests.swift
//  TimeScrollDevTests
//

import Foundation
import Testing
@testable import TimeScroll

@MainActor
struct CaptureRetryLoopTests {
    @Test func keeps_retrying_after_the_backoff_table_is_exhausted() async {
        var slept: [Double] = []
        var attempts = 0
        let loop = CaptureRetryLoop(delays: [1, 2, 3]) { slept.append($0) }

        loop.start {
            attempts += 1
            return attempts == 8
        }
        while loop.isActive { await Task.yield() }

        #expect(attempts == 8)
        #expect(slept == [1, 2, 3, 3, 3, 3, 3, 3])
    }

    @Test func starting_again_begins_the_backoff_from_the_first_delay() async {
        var slept: [Double] = []
        var attempts = 0
        let loop = CaptureRetryLoop(delays: [1, 2, 3]) { slept.append($0) }

        loop.start {
            attempts += 1
            guard attempts == 2 else { return false }
            // The display woke up mid-backoff: replace the loop that is running this attempt.
            loop.start { true }
            return false
        }
        while loop.isActive { await Task.yield() }

        #expect(attempts == 2)
        #expect(slept == [1, 2, 1])
    }

    @Test func cancel_stops_retrying() async {
        var attempts = 0
        let loop = CaptureRetryLoop(delays: [1]) { _ in await Task.yield() }

        loop.start {
            attempts += 1
            return false
        }
        while attempts < 3, loop.isActive { await Task.yield() }
        #expect(loop.isActive)

        loop.cancel()
        let attemptsAtCancel = attempts
        for _ in 0..<50 { await Task.yield() }

        #expect(attempts == attemptsAtCancel)
        #expect(!loop.isActive)
    }
}
