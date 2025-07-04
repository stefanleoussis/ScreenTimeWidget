import SwiftUI

struct TotalActivityView: View {
    let totalActivity: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.primary)
                Text("Total Screen Time")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            Text(totalActivity)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
            
            Text("Today")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// In order to support previews for your extension's custom views, make sure its source files are
// members of your app's Xcode target as well as members of your extension's target. You can use
// Xcode's File Inspector to modify a file's Target Membership.
#Preview {
    TotalActivityView(totalActivity: "2h 30m")
}
