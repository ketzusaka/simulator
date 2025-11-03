import Foundation
@testable import Simulator
import Testing

struct FlightSimulatorTests {
    @Test func testEmptyFlightPathError() async throws {
        let mockNetworking = MockTelemetryPublisher()
        let simulator = FlightSimulator(telemetryPublisher: mockNetworking, rid: "RID-TEST-1")

        // Create a temporary empty GeoJSON file
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent("empty-flight.geojson")

        let emptyJson = """
        {
            "type": "FeatureCollection",
            "properties": {
                "rid": "RID-TEST-1"
            },
            "features": []
        }
        """

        try emptyJson.write(to: tempFile, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: tempFile) }

        await #expect(throws: FlightSimulatorError.emptyFlightPath) {
            try await simulator.simulateFlight(from: tempFile.path)
        }
    }

    @Test func testFileNotFoundError() async throws {
        let mockNetworking = MockTelemetryPublisher()
        let simulator = FlightSimulator(telemetryPublisher: mockNetworking, rid: "RID-TEST-1")

        await #expect(throws: FlightSimulatorError.fileNotFound("/nonexistent/path.geojson")) {
            try await simulator.simulateFlight(from: "/nonexistent/path.geojson")
        }
    }

    @Test func testSuccessfulFlightSimulation() async throws {
        let mockNetworking = MockTelemetryPublisher()
        let simulator = FlightSimulator(telemetryPublisher: mockNetworking, rid: "RID-TEST-1")

        // Create a temporary GeoJSON file with one waypoint
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent("test-flight.geojson")

        let testJson = """
        {
            "type": "FeatureCollection",
            "properties": {
                "rid": "RID-TEST-1"
            },
            "features": [
                {
                    "type": "Feature",
                    "geometry": {
                        "type": "Point",
                        "coordinates": [-122.404, 37.806, 95.2]
                    },
                    "properties": {
                        "timestamp": 0,
                        "speed_meters_per_second": 0.0,
                        "heading_degrees": 0.0
                    }
                }
            ]
        }
        """

        try testJson.write(to: tempFile, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: tempFile) }

        try await simulator.simulateFlight(from: tempFile.path)

        let sentTelemetry = await mockNetworking.sendTelemetryInvocatedParameters
        #expect(sentTelemetry.count == 1)
        #expect(sentTelemetry[0].rid == "RID-TEST-1")
        #expect(sentTelemetry[0].lat == 37.806)
        #expect(sentTelemetry[0].lon == -122.404)
    }

    @Test func testNetworkFailure() async throws {
        let mockNetworking = MockTelemetryPublisher()
        await mockNetworking.setStubSendTelemetry { _ in
            throw MQTTError.publishFailed(message: "Network error")
        }

        let simulator = FlightSimulator(telemetryPublisher: mockNetworking, rid: "RID-TEST-1")

        // Create a temporary GeoJSON file
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent("test-flight.geojson")

        let testJson = """
        {
            "type": "FeatureCollection",
            "properties": {
                "rid": "RID-TEST-1"
            },
            "features": [
                {
                    "type": "Feature",
                    "geometry": {
                        "type": "Point",
                        "coordinates": [-122.404, 37.806, 95.2]
                    },
                    "properties": {
                        "timestamp": 0,
                        "speed_meters_per_second": 0.0,
                        "heading_degrees": 0.0
                    }
                }
            ]
        }
        """

        try testJson.write(to: tempFile, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: tempFile) }

        await #expect(throws: MQTTError.self) {
            try await simulator.simulateFlight(from: tempFile.path)
        }
    }
}
