import Foundation

// MARK: - Flight Waypoint

struct FlightWaypoint {
    let timestamp: Double // seconds from start
    let longitude: Double
    let latitude: Double
    let altitude: Double?
    let speed: Double?
    let heading: Double?

    init(from feature: GeoJSONFeature) {
        self.timestamp = feature.properties.timestamp
        self.longitude = feature.geometry.longitude
        self.latitude = feature.geometry.latitude
        self.altitude = feature.geometry.altitude
        self.speed = feature.properties.speedMetersPerSecond
        self.heading = feature.properties.headingDegrees
    }

    init(timestamp: Double, longitude: Double, latitude: Double, altitude: Double?, speed: Double?, heading: Double?) {
        self.timestamp = timestamp
        self.longitude = longitude
        self.latitude = latitude
        self.altitude = altitude
        self.speed = speed
        self.heading = heading
    }

    func toTelemetrySample(rid: String, startTime: Date) -> TelemetrySample {
        let currentTime = startTime.addingTimeInterval(timestamp)
        let iso8601Timestamp = ISO8601DateFormatter().string(from: currentTime)

        return TelemetrySample(
            eventId: UUID().uuidString,
            ts: iso8601Timestamp,
            rid: rid,
            lat: latitude,
            lon: longitude,
            altitudeMeters: altitude,
            speedMetersPerSecond: speed,
            headingDegrees: heading
        )
    }
}
