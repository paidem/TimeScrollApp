import SwiftUI

struct TimelineDayControls: View {
    @ObservedObject var model: TimelineModel

    var body: some View {
        HStack(spacing: 12) {
            Picker("Timeline", selection: Binding(get: { model.dayMode }, set: { model.setDayMode($0) })) {
                Text("Continuous").tag(false)
                Text("Day").tag(true)
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .fixedSize()
            .help("Continuous timeline, or one day at a time")
            if model.dayMode { TimelineDayNavigator(model: model) }
        }
    }
}
