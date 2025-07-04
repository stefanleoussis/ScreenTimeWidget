import DeviceActivity
import SwiftUI

extension DeviceActivityReport.Context {
    static let totalActivity = Self("Total Activity")
}

struct TotalActivityReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .totalActivity
    let content: (String) -> TotalActivityView
    
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> String {
        // Use the original Apple approach with our enhancements
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        
        // Process the activity data using Apple's recommended approach
        let totalActivityDuration = await data.flatMap { $0.activitySegments }.reduce(0, {
            $0 + $1.totalActivityDuration
        })
        
        // Format the duration for better readability
        let formattedDuration = formatDuration(totalActivityDuration)
        
        // Save to App Groups so widget can access it
        saveScreenTimeToSharedStorage(formattedDuration)
        
        return formattedDuration
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours == 0 && minutes == 0 {
            return "0m"
        } else if hours == 0 {
            return "\(minutes)m"
        } else if minutes == 0 {
            return "\(hours)h"
        } else {
            return "\(hours)h \(minutes)m"
        }
    }
    
    private func saveScreenTimeToSharedStorage(_ screenTime: String) {
        // Save to App Groups so widget can access it
        if let sharedDefaults = UserDefaults(suiteName: "group.com.azexpoglobe.ScreenTimeWidget") {
            sharedDefaults.set(screenTime, forKey: "screenTimeData")
            sharedDefaults.set(Date(), forKey: "lastUpdateTime")
            sharedDefaults.set("real", forKey: "dataSource") // Mark as real data
            
            // Debug logging (this will help us verify it's working)
            print("Screen Time saved: \(screenTime)")
        } else {
            print("Failed to access shared UserDefaults")
        }
    }
}
