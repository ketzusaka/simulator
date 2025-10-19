import Foundation

// MARK: - Telemetry Models

struct TelemetrySample: Codable {
    let eventId: String?
    let ts: String // ISO 8601 timestamp
    let rid: String
    let lat: Double
    let lon: Double
    let altitudeMeters: Double?
    let speedMetersPerSecond: Double?
    let headingDegrees: Double?
    
    enum CodingKeys: String, CodingKey {
        case eventId = "event_id"
        case ts, rid, lat, lon
        case altitudeMeters = "altitude_meters"
        case speedMetersPerSecond = "speed_meters_per_second"
        case headingDegrees = "heading_degrees"
    }
}
