import Foundation

struct BikeWorkoutData: Codable {
    let duration: TimeInterval          // in seconds
    let distance: Double                // in kilometers
    let averageHeartRate: Double        // in bpm
    let averageCadence: Double          // in rpm
    let averageResistance: Double       // normalized 0-1
    let heartRateSamples: [HeartRateSample]
    let cadenceSamples: [CadenceSample]
    let resistanceSamples: [ResistanceSample]
    let startDate: Date
    let endDate: Date
    
    enum CodingKeys: String, CodingKey {
        case duration
        case distance
        case averageHeartRate = "average_heart_rate"
        case averageCadence = "average_cadence"
        case averageResistance = "average_resistance"
        case heartRateSamples = "heart_rate_samples"
        case cadenceSamples = "cadence_samples"
        case resistanceSamples = "resistance_samples"
        case startDate = "start_date"
        case endDate = "end_date"
    }
}

struct HeartRateSample: Codable {
    let timestamp: Date
    let value: Double  // bpm
}

struct CadenceSample: Codable {
    let timestamp: Date
    let value: Double  // rpm
}

struct ResistanceSample: Codable {
    let timestamp: Date
    let value: Double  // normalized 0-1
}
