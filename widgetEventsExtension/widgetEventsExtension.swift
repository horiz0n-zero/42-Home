
import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct widgetEventsExtensionEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            Image(uiImage: HomeWidgets.coalitionBackground)
            VStack {
                HStack {
                    Text("connectez vous pour utiliser l'app")
                }
            }
        }
    }
}

@main
struct widgetEventsExtension: Widget {
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: HomeWidgets.Kind.events.rawValue, provider: Provider()) { entry in
            widgetEventsExtensionEntryView(entry: entry)
        }
        .configurationDisplayName(HomeWidgets.Kind.events.displayName)
        .description(HomeWidgets.Kind.events.description)
        .supportedFamilies(HomeWidgets.Kind.events.families)
    }
}

struct widgetEventsExtension_Previews: PreviewProvider {
    static var previews: some View {
        widgetEventsExtensionEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
