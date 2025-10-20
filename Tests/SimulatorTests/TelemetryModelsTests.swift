import Foundation
@testable import Simulator
import Testing

struct TelemetryModelsTests {
    @Test func testTelemetrySampleCreation() throws {
        let telemetry = TelemetrySample(
            eventId: "test-event-id",
            ts: "2025-10-19T04:50:00Z",
            rid: "RID-TEST-1",
            lat: 37.806,
            lon: -122.404,
            altitudeMeters: 95.2,
            speedMetersPerSecond: 11.9,
            headingDegrees: 210.0
        )

        #expect(telemetry.eventId == "test-event-id")
        #expect(telemetry.ts == "2025-10-19T04:50:00Z")
        #expect(telemetry.rid == "RID-TEST-1")
        #expect(telemetry.lat == 37.806)
        #expect(telemetry.lon == -122.404)
        #expect(telemetry.altitudeMeters == 95.2)
        #expect(telemetry.speedMetersPerSecond == 11.9)
        #expect(telemetry.headingDegrees == 210.0)
    }

    @Test func testTelemetrySampleWithNilValues() throws {
        let telemetry = TelemetrySample(
            eventId: nil,
            ts: "2025-10-19T04:50:00Z",
            rid: "RID-TEST-1",
            lat: 37.806,
            lon: -122.404,
            altitudeMeters: nil,
            speedMetersPerSecond: nil,
            headingDegrees: nil
        )

        #expect(telemetry.eventId == nil)
        #expect(telemetry.ts == "2025-10-19T04:50:00Z")
        #expect(telemetry.rid == "RID-TEST-1")
        #expect(telemetry.lat == 37.806)
        #expect(telemetry.lon == -122.404)
        #expect(telemetry.altitudeMeters == nil)
        #expect(telemetry.speedMetersPerSecond == nil)
        #expect(telemetry.headingDegrees == nil)
    }

    @Test func testTelemetrySampleEncoding() throws {
        let telemetry = TelemetrySample(
            eventId: "test-event-id",
            ts: "2025-10-19T04:50:00Z",
            rid: "RID-TEST-1",
            lat: 37.806,
            lon: -122.404,
            altitudeMeters: 95.2,
            speedMetersPerSecond: 11.9,
            headingDegrees: 210.0
        )

        let data = try JSONEncoder().encode(telemetry)
        let decoded = try JSONDecoder().decode(TelemetrySample.self, from: data)

        #expect(decoded.eventId == "test-event-id")
        #expect(decoded.ts == "2025-10-19T04:50:00Z")
        #expect(decoded.rid == "RID-TEST-1")
        #expect(decoded.lat == 37.806)
        #expect(decoded.lon == -122.404)
        #expect(decoded.altitudeMeters == 95.2)
        #expect(decoded.speedMetersPerSecond == 11.9)
        #expect(decoded.headingDegrees == 210.0)
    }

    @Test func testTelemetrySampleDecoding() throws {
        let json = """
        {
            "event_id": "test-event-id",
            "ts": "2025-10-19T04:50:00Z",
            "rid": "RID-TEST-1",
            "lat": 37.806,
            "lon": -122.404,
            "altitude_meters": 95.2,
            "speed_meters_per_second": 11.9,
            "heading_degrees": 210.0
        }
        """

        let data = json.data(using: .utf8)!
        let telemetry = try JSONDecoder().decode(TelemetrySample.self, from: data)

        #expect(telemetry.eventId == "test-event-id")
        #expect(telemetry.ts == "2025-10-19T04:50:00Z")
        #expect(telemetry.rid == "RID-TEST-1")
        #expect(telemetry.lat == 37.806)
        #expect(telemetry.lon == -122.404)
        #expect(telemetry.altitudeMeters == 95.2)
        #expect(telemetry.speedMetersPerSecond == 11.9)
        #expect(telemetry.headingDegrees == 210.0)
    }

    @Test func testTelemetrySampleProperties() throws {
        let telemetry = TelemetrySample(
            eventId: "test-event-id",
            ts: "2025-10-19T04:50:00Z",
            rid: "RID-TEST-1",
            lat: 37.806,
            lon: -122.404,
            altitudeMeters: 95.2,
            speedMetersPerSecond: 11.9,
            headingDegrees: 210.0
        )

        // Test individual properties
        #expect(telemetry.eventId == "test-event-id")
        #expect(telemetry.ts == "2025-10-19T04:50:00Z")
        #expect(telemetry.rid == "RID-TEST-1")
        #expect(telemetry.lat == 37.806)
        #expect(telemetry.lon == -122.404)
        #expect(telemetry.altitudeMeters == 95.2)
        #expect(telemetry.speedMetersPerSecond == 11.9)
        #expect(telemetry.headingDegrees == 210.0)
    }
}
