
import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        print(#function)
        return SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
        print(#function)
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
        print(#function)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct widgetClusterPeoplesEntryView : View {
    var entry: Provider.Entry
    
    func getController() -> String {
        return HomeDefaults.read(.controller) ?? "no controller found"
    }
    
    var body: some View {
        Text(entry.date, style: .time)
    }
}

@main struct widgetClusterPeoples: Widget {
    
    @Environment(\.openURL) var openUrl: OpenURLAction
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "widgetClusterPeoples", provider: Provider()) { entry in
            widgetClusterPeoplesEntryView(entry: entry)
        }
        .configurationDisplayName("Cluster Peoples")
        .description("This is an example widget.")
        .supportedFamilies([.systemMedium])
    }
}

struct widgetClusterPeoples_Previews: PreviewProvider {
    static var previews: some View {
        widgetClusterPeoplesEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
