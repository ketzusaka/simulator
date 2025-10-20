import Foundation

actor FlightSimulator {
    private let strataNetworking: any StrataNetworking
    private let rid: String

    init(strataNetworking: any StrataNetworking, rid: String) {
        self.strataNetworking = strataNetworking
        self.rid = rid
    }

    func simulateFlight(from filePath: String) async throws {
        print("🛩️  Loading flight path from: \(filePath)")

        // Load and parse GeoJSON file
        let flightPath = try loadFlightPath(from: filePath)
        let waypoints = flightPath.features.map { FlightWaypoint(from: $0) }

        guard !waypoints.isEmpty else {
            throw FlightSimulatorError.emptyFlightPath
        }

        print("📍 Found \(waypoints.count) waypoints")
        print("🚀 Starting flight simulation...")

        let startTime = Date()

        for (index, waypoint) in waypoints.enumerated() {
            // Calculate delay until this waypoint should be sent
            if index > 0 {
                let previousWaypoint = waypoints[index - 1]
                let delay = waypoint.timestamp - previousWaypoint.timestamp

                if delay > 0 {
                    print("⏱️  Waiting \(String(format: "%.1f", delay)) seconds...")
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }

            // Generate telemetry sample
            let telemetry = waypoint.toTelemetrySample(rid: rid, startTime: startTime)

            // Send to Strata
            do {
                try await strataNetworking.sendTelemetry(telemetry)
                let altitudeText = waypoint.altitude != nil ? "\(String(format: "%.1f", waypoint.altitude!))m" : "N/A"
                print("📍 Waypoint \(index + 1)/\(waypoints.count): lat=\(String(format: "%.6f", waypoint.latitude)), lon=\(String(format: "%.6f", waypoint.longitude)), alt=\(altitudeText)")
            } catch {
                print("❌ Failed to send waypoint \(index + 1): \(error.localizedDescription)")
                throw error
            }
        }

        let totalDuration = Date().timeIntervalSince(startTime)
        print("✅ Flight simulation completed in \(String(format: "%.1f", totalDuration)) seconds")
    }

    private func loadFlightPath(from filePath: String) throws -> GeoJSONFeatureCollection {
        let url = URL(fileURLWithPath: filePath)

        guard FileManager.default.fileExists(atPath: filePath) else {
            throw FlightSimulatorError.fileNotFound(filePath)
        }

        let data = try Data(contentsOf: url)

        do {
            return try JSONDecoder().decode(GeoJSONFeatureCollection.self, from: data)
        } catch {
            throw FlightSimulatorError.invalidGeoJSON(error.localizedDescription)
        }
    }
}

enum FlightSimulatorError: Error, LocalizedError, Equatable {
    case fileNotFound(String)
    case invalidGeoJSON(String)
    case emptyFlightPath

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let path):
            "Flight path file not found: \(path)"
        case .invalidGeoJSON(let message):
            "Invalid GeoJSON format: \(message)"
        case .emptyFlightPath:
            "Flight path contains no waypoints"
        }
    }

    static func == (lhs: FlightSimulatorError, rhs: FlightSimulatorError) -> Bool {
        switch (lhs, rhs) {
        case (.fileNotFound(let lhsPath), .fileNotFound(let rhsPath)):
            lhsPath == rhsPath
        case (.invalidGeoJSON(let lhsMessage), .invalidGeoJSON(let rhsMessage)):
            lhsMessage == rhsMessage
        case (.emptyFlightPath, .emptyFlightPath):
            true
        default:
            false
        }
    }
}
