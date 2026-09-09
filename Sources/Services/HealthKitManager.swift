import Foundation
import HealthKit

class HealthKitManager {
    private let healthStore = HKHealthStore()
    
    private let typesToRead: Set<HKSampleType> = [
        HKObjectType.workoutType(),
        HKQuantityType.quantityType(forIdentifier: .heartRate)!,
        HKQuantityType.quantityType(forIdentifier: .cyclingCadence)!,
        HKQuantityType.quantityType(forIdentifier: .cyclingFunctionalThresholdPower)!
    ]
    
    private let typesToWrite: Set<HKSampleType> = [
        HKObjectType.workoutType(),
        HKQuantityType.quantityType(forIdentifier: .heartRate)!,
        HKQuantityType.quantityType(forIdentifier: .cyclingCadence)!,
        HKQuantityType.quantityType(forIdentifier: .cyclingFunctionalThresholdPower)!
    ]
    
    func checkAuthorization() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            return false
        }
        
        // Check if authorization has been requested before
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let status = healthStore.authorizationStatus(for: heartRateType)
        return status == .sharingAuthorized
    }
    
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.healthDataNotAvailable
        }
        
        try await healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead)
    }
    
    func saveBikeWorkout(
        duration: TimeInterval,
        distance: Double,
        heartRateSamples: [HeartRateSample],
        cadenceSamples: [CadenceSample],
        resistanceSamples: [ResistanceSample]
    ) async throws {
        let startDate = Date(timeIntervalSinceNow: -duration)
        let endDate = Date()
        
        // Create workout
        let workout = HKWorkout(
            activityType: .cycling,
            start: startDate,
            end: endDate,
            duration: duration,
            totalEnergyBurned: nil,
            totalDistance: HKQuantity(unit: .kilometer(), doubleValue: distance),
            metadata: [
                HKMetadataKeyWorkoutBrandName: "Bike Workout Health Kit Mac",
                HKMetadataKeyTimeZone: TimeZone.current.identifier
            ]
        )
        
        // Prepare samples
        var samplesToSave: [HKSample] = [workout]
        
        // Add heart rate samples
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        for sample in heartRateSamples {
            let quantity = HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: sample.value)
            let heartRateSample = HKQuantitySample(
                type: heartRateType,
                quantity: quantity,
                start: sample.timestamp,
                end: sample.timestamp
            )
            samplesToSave.append(heartRateSample)
        }
        
        // Add cadence samples
        let cadenceType = HKQuantityType.quantityType(forIdentifier: .cyclingCadence)!
        for sample in cadenceSamples {
            let quantity = HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: sample.value)
            let cadenceSample = HKQuantitySample(
                type: cadenceType,
                quantity: quantity,
                start: sample.timestamp,
                end: sample.timestamp
            )
            samplesToSave.append(cadenceSample)
        }
        
        // Add resistance samples (using cycling power as proxy)
        let powerType = HKQuantityType.quantityType(forIdentifier: .cyclingFunctionalThresholdPower)!
        for sample in resistanceSamples {
            // Scale resistance (0-1) to a reasonable power range (0-500W)
            let powerValue = sample.value * 500
            let quantity = HKQuantity(unit: .watt(), doubleValue: powerValue)
            let powerSample = HKQuantitySample(
                type: powerType,
                quantity: quantity,
                start: sample.timestamp,
                end: sample.timestamp
            )
            samplesToSave.append(powerSample)
        }
        
        // Save all samples
        try await healthStore.save(samplesToSave)
    }
}

enum HealthKitError: LocalizedError {
    case healthDataNotAvailable
    case saveFailed(String)
    case authorizationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .healthDataNotAvailable:
            return "Health data is not available on this device"
        case .saveFailed(let message):
            return "Failed to save to HealthKit: \(message)"
        case .authorizationFailed(let message):
            return "HealthKit authorization failed: \(message)"
        }
    }
}
