import Foundation
import HealthKit

@MainActor
class WorkoutViewModel: NSObject, ObservableObject {
    @Published var currentWorkout: BikeWorkoutData?
    @Published var isLoading = false
    @Published var healthKitAuthorized = false
    @Published var lastSyncTime: Date?
    
    private let healthKitManager = HealthKitManager()
    private let apiClient = APIClient()
    
    override init() {
        super.init()
        checkHealthKitAuthorization()
    }
    
    private func checkHealthKitAuthorization() {
        Task {
            self.healthKitAuthorized = await healthKitManager.checkAuthorization()
        }
    }
    
    func requestHealthKitAuth() async throws {
        try await healthKitManager.requestAuthorization()
        self.healthKitAuthorized = true
    }
    
    func fetchAndSaveWorkout(from urlString: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        // Fetch workout data from REST API
        let workoutData = try await apiClient.fetchWorkout(from: urlString)
        
        // Update UI with fetched data
        self.currentWorkout = workoutData
        
        // Save to Apple Health
        try await healthKitManager.saveBikeWorkout(
            duration: workoutData.duration,
            distance: workoutData.distance,
            heartRateSamples: workoutData.heartRateSamples,
            cadenceSamples: workoutData.cadenceSamples,
            resistanceSamples: workoutData.resistanceSamples
        )
        
        // Update last sync time
        self.lastSyncTime = Date()
    }
}
