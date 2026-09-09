import SwiftUI
import HealthKit

struct ContentView: View {
    @StateObject private var viewModel = WorkoutViewModel()
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var restApiUrl = "https://api.example.com/workout"
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "bicycle")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Bike Workout Sync")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("Sync workouts from API to Apple Health")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding()
                Divider()
            }
            .background(Color(.controlBackgroundColor))
            
            // Main Content
            TabView(selection: $selectedTab) {
                // Sync Tab
                VStack(spacing: 16) {
                    Form {
                        Section(header: Text("API Configuration")) {
                            TextField("REST API URL", text: $restApiUrl)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        Section(header: Text("Actions")) {
                            HStack(spacing: 12) {
                                Button(action: fetchAndSaveWorkout) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "arrow.down.circle.fill")
                                        Text("Fetch & Sync")
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                .controlSize(.large)
                                
                                if viewModel.isLoading {
                                    ProgressView()
                                        .scaleEffect(0.8, anchor: .center)
                                }
                            }
                        }
                    }
                    .formStyle(.grouped)
                    
                    Spacer()
                }
                .tabItem {
                    Label("Sync", systemImage: "arrow.triangle.2.circlepath")
                }
                .tag(0)
                
                // Workout Details Tab
                VStack {
                    if let workout = viewModel.currentWorkout {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                // Summary Card
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Workout Summary")
                                        .font(.headline)
                                    Divider()
                                    
                                    HStack(spacing: 24) {
                                        StatCard(
                                            title: "Duration",
                                            value: formatDuration(workout.duration),
                                            icon: "clock.fill"
                                        )
                                        StatCard(
                                            title: "Distance",
                                            value: String(format: "%.2f km", workout.distance),
                                            icon: "location.fill"
                                        )
                                        StatCard(
                                            title: "Avg HR",
                                            value: "\(Int(workout.averageHeartRate)) bpm",
                                            icon: "heart.fill"
                                        )
                                    }
                                    
                                    HStack(spacing: 24) {
                                        StatCard(
                                            title: "Avg Cadence",
                                            value: "\(Int(workout.averageCadence)) rpm",
                                            icon: "gear"
                                        )
                                        StatCard(
                                            title: "Avg Resistance",
                                            value: String(format: "%.1f%%", workout.averageResistance * 100),
                                            icon: "bolt.fill"
                                        )
                                    }
                                }
                                .padding()
                                .background(Color(.controlBackgroundColor))
                                .cornerRadius(8)
                                
                                // Detailed Metrics
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Detailed Metrics")
                                        .font(.headline)
                                    Divider()
                                    
                                    MetricRow(
                                        label: "Total Duration",
                                        value: "\(Int(workout.duration)) seconds"
                                    )
                                    MetricRow(
                                        label: "Total Distance",
                                        value: String(format: "%.2f km", workout.distance)
                                    )
                                    MetricRow(
                                        label: "Start Date",
                                        value: formatDate(workout.startDate)
                                    )
                                    MetricRow(
                                        label: "End Date",
                                        value: formatDate(workout.endDate)
                                    )
                                    MetricRow(
                                        label: "Heart Rate Samples",
                                        value: "\(workout.heartRateSamples.count)"
                                    )
                                    MetricRow(
                                        label: "Cadence Samples",
                                        value: "\(workout.cadenceSamples.count)"
                                    )
                                    MetricRow(
                                        label: "Resistance Samples",
                                        value: "\(workout.resistanceSamples.count)"
                                    )
                                }
                                .padding()
                                .background(Color(.controlBackgroundColor))
                                .cornerRadius(8)
                            }
                            .padding()
                        }
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "bicycle")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                            Text("No Workout Data")
                                .font(.headline)
                            Text("Sync a workout to view details here")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .tabItem {
                    Label("Details", systemImage: "chart.bar.fill")
                }
                .tag(1)
                
                // Status Tab
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("HealthKit Status")
                            .font(.headline)
                        Divider()
                        
                        HStack {
                            Image(systemName: viewModel.healthKitAuthorized ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(viewModel.healthKitAuthorized ? .green : .red)
                            Text(viewModel.healthKitAuthorized ? "HealthKit Authorized" : "HealthKit Not Authorized")
                            Spacer()
                        }
                        
                        if !viewModel.healthKitAuthorized {
                            Button("Request Authorization") {
                                Task {
                                    try? await viewModel.requestHealthKitAuth()
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding()
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Activity")
                            .font(.headline)
                        Divider()
                        
                        if let lastSync = viewModel.lastSyncTime {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                VStack(alignment: .leading) {
                                    Text("Last Sync")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(formatDate(lastSync))
                                }
                                Spacer()
                            }
                        } else {
                            Text("No sync history")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(8)
                    
                    Spacer()
                }
                .padding()
                .tabItem {
                    Label("Status", systemImage: "info.circle.fill")
                }
                .tag(2)
            }
            .padding(0)
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func fetchAndSaveWorkout() {
        Task {
            do {
                try await viewModel.fetchAndSaveWorkout(from: restApiUrl)
                alertTitle = "Success"
                alertMessage = "Workout successfully synced to Apple Health!"
                showAlert = true
                selectedTab = 1 // Switch to details tab
            } catch {
                alertTitle = "Error"
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        
        if hours > 0 {
            return String(format: "%dh %dm %ds", hours, minutes, secs)
        } else if minutes > 0 {
            return String(format: "%dm %ds", minutes, secs)
        } else {
            return String(format: "%ds", secs)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.blue)
            VStack(spacing: 2) {
                Text(value)
                    .font(.headline)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct MetricRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .monospaced()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
}
