import SwiftUI

struct TimelineDayNavigator: View {
    @ObservedObject var model: TimelineModel
    @State private var showCalendar = false

    var body: some View {
        HStack(spacing: 2) {
            Button { model.stepDay(by: -1) } label: { Image(systemName: "chevron.left") }
                .help("Previous day with captures")

            Button { showCalendar.toggle() } label: {
                Text(title).frame(minWidth: 72)
            }
            .help("Pick a day")
            .popover(isPresented: $showCalendar, arrowEdge: .bottom) {
                DatePicker("Day", selection: Binding(get: { model.day }, set: { date in
                    showCalendar = false
                    model.showDay(date)
                }), in: ...Date(), displayedComponents: .date)
                .datePickerStyle(.graphical)
                .labelsHidden()
                .padding(12)
            }

            Button { model.stepDay(by: 1) } label: { Image(systemName: "chevron.right") }
                .help("Next day with captures")
                .disabled(Calendar.current.isDateInToday(model.day))

            if model.dayZoom > 1 {
                Button { model.dayZoom = 1 } label: { Image(systemName: "arrow.left.and.right") }
                    .help("Fit the whole day")
            }
        }
        .buttonStyle(.borderless)
    }

    private var title: String {
        Calendar.current.isDateInToday(model.day)
            ? "Today"
            : model.day.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))
    }
}

