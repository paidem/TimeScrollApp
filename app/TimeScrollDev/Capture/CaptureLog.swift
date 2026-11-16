import os
import Foundation

enum CaptureLog {
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "TimeScroll", category: "capture")
}
