import Testing
import Foundation
@testable import Simulator

struct FlightWaypointTests {
    
    @Test func testFlightWaypointCreationFromFeature() throws {
        let json = """
        {
            "type": "Feature",
            "geometry": {
                "type": "Point",
                "coordinates": [-122.404, 37.806, 95.2]
            },
            "properties": {
                "timestamp": 5,
                "speed_meters_per_second": 11.9,
                "heading_degrees": 210.0
            }
        }
        """
        
        let data = json.data(using: .utf8)!
        let feature = try JSONDecoder().decode(GeoJSONFeature.self, from: data)
        let waypoint = FlightWaypoint(from: feature)
        
        #expect(waypoint.timestamp == 5)
        #expect(waypoint.longitude == -122.404)
        #expect(waypoint.latitude == 37.806)
        #expect(waypoint.altitude == 95.2)
        #expect(waypoint.speed == 11.9)
        #expect(waypoint.heading == 210.0)
    }
    
    @Test func testFlightWaypointDirectCreation() throws {
        let waypoint = FlightWaypoint(
            timestamp: 10,
            longitude: -122.404,
            latitude: 37.806,
            altitude: 95.2,
            speed: 11.9,
            heading: 210.0
        )
        
        #expect(waypoint.timestamp == 10)
        #expect(waypoint.longitude == -122.404)
        #expect(waypoint.latitude == 37.806)
        #expect(waypoint.altitude == 95.2)
        #expect(waypoint.speed == 11.9)
        #expect(waypoint.heading == 210.0)
    }
    
    @Test func testFlightWaypointWithNilValues() throws {
        let waypoint = FlightWaypoint(
            timestamp: 15,
            longitude: -122.404,
            latitude: 37.806,
            altitude: nil,
            speed: nil,
            heading: nil
        )
        
        #expect(waypoint.timestamp == 15)
        #expect(waypoint.longitude == -122.404)
        #expect(waypoint.latitude == 37.806)
        #expect(waypoint.altitude == nil)
        #expect(waypoint.speed == nil)
        #expect(waypoint.heading == nil)
    }
    
    @Test func testFlightWaypointCreationFromFeatureWithoutAltitude() throws {
        let json = """
        {
            "type": "Feature",
            "geometry": {
                "type": "Point",
                "coordinates": [-122.404, 37.806]
            },
            "properties": {
                "timestamp": 5,
                "speed_meters_per_second": 11.9,
                "heading_degrees": 210.0
            }
        }
        """
        
        let data = json.data(using: .utf8)!
        let feature = try JSONDecoder().decode(GeoJSONFeature.self, from: data)
        let waypoint = FlightWaypoint(from: feature)
        
        #expect(waypoint.timestamp == 5)
        #expect(waypoint.longitude == -122.404)
        #expect(waypoint.latitude == 37.806)
        #expect(waypoint.altitude == nil)
        #expect(waypoint.speed == 11.9)
        #expect(waypoint.heading == 210.0)
    }
    
    @Test func testFlightWaypointToTelemetrySample() throws {
        let waypoint = FlightWaypoint(
            timestamp: 10,
            longitude: -122.404,
            latitude: 37.806,
            altitude: 95.2,
            speed: 11.9,
            heading: 210.0
        )
        
        let startTime = Date(timeIntervalSince1970: 1000000000) // Fixed timestamp
        let telemetry = waypoint.toTelemetrySample(rid: "RID-TEST-1", startTime: startTime)
        
        #expect(telemetry.rid == "RID-TEST-1")
        #expect(telemetry.lat == 37.806)
        #expect(telemetry.lon == -122.404)
        #expect(telemetry.altitudeMeters == 95.2)
        #expect(telemetry.speedMetersPerSecond == 11.9)
        #expect(telemetry.headingDegrees == 210.0)
        #expect(telemetry.eventId != nil)
        #expect(!telemetry.ts.isEmpty)
    }
    
    @Test func testFlightWaypointToTelemetrySampleWithNilValues() throws {
        let waypoint = FlightWaypoint(
            timestamp: 10,
            longitude: -122.404,
            latitude: 37.806,
            altitude: nil,
            speed: nil,
            heading: nil
        )
        
        let startTime = Date(timeIntervalSince1970: 1000000000) // Fixed timestamp
        let telemetry = waypoint.toTelemetrySample(rid: "RID-TEST-1", startTime: startTime)
        
        #expect(telemetry.rid == "RID-TEST-1")
        #expect(telemetry.lat == 37.806)
        #expect(telemetry.lon == -122.404)
        #expect(telemetry.altitudeMeters == nil)
        #expect(telemetry.speedMetersPerSecond == nil)
        #expect(telemetry.headingDegrees == nil)
        #expect(telemetry.eventId != nil)
        #expect(!telemetry.ts.isEmpty)
    }
}
