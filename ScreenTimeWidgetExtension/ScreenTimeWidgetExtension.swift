import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), screenTime: "Loading...")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), screenTime: "2h 30m")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // For now, we'll create a simple timeline with mock data
        let currentDate = Date()
        let screenTime = getScreenTimeFromSharedData() ?? "No data"
        
        let entry = SimpleEntry(date: currentDate, screenTime: screenTime)
        
        // Update every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
    
    private func getScreenTimeFromSharedData() -> String? {
        // Read from App Groups shared data
        let sharedDefaults = UserDefaults(suiteName: "group.com.azexpoglobe.ScreenTimeWidget")
        
        // Check if data exists and is recent (within last 24 hours)
        if let screenTimeData = sharedDefaults?.string(forKey: "screenTimeData"),
           let lastUpdate = sharedDefaults?.object(forKey: "lastUpdateTime") as? Date {
            
            let timeSinceUpdate = Date().timeIntervalSince(lastUpdate)
            if timeSinceUpdate < 24 * 60 * 60 { // Less than 24 hours old
                return screenTimeData
            }
        }
        
        return nil
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let screenTime: String
}

struct ScreenTimeWidgetExtensionEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        switch entry.screenTime {
        case "Loading...":
            Text("Loading...")
                .font(.caption2)
                .foregroundColor(.secondary)
        case "No data":
            Text("No screen time data")
                .font(.caption2)
                .foregroundColor(.secondary)
        default:
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.caption2)
                    .foregroundColor(.primary)
                Text(entry.screenTime)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
        }
    }
}

struct ScreenTimeWidgetExtension: Widget {
    let kind: String = "ScreenTimeWidgetExtension"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ScreenTimeWidgetExtensionEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Screen Time")
        .description("Shows your daily screen time on the lock screen")
        .supportedFamilies([
            .accessoryInline,      // Lock screen inline widget
            .accessoryCircular,    // Lock screen circular widget (bonus)
            .accessoryRectangular  // Lock screen rectangular widget (bonus)
        ])
    }
}

struct ScreenTimeWidgetExtension_Previews: PreviewProvider {
    static var previews: some View {
        ScreenTimeWidgetExtensionEntryView(entry: SimpleEntry(date: Date(), screenTime: "2h 30m"))
            .previewContext(WidgetPreviewContext(family: .accessoryInline))
    }
}
