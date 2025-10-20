import Foundation
@testable import Simulator
import Testing

struct GeoJSONModelsTests {
    @Test func testGeoJSONFeatureCollectionParsing() throws {
        let json = """
        {
            "type": "FeatureCollection",
            "properties": {
                "rid": "RID-TEST-1",
                "description": "Test flight"
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

        let data = json.data(using: .utf8)!
        let flightPath = try JSONDecoder().decode(GeoJSONFeatureCollection.self, from: data)

        #expect(flightPath.type == "FeatureCollection")
        #expect(flightPath.properties?.rid == "RID-TEST-1")
        #expect(flightPath.features.count == 1)

        let feature = flightPath.features[0]
        #expect(feature.geometry.longitude == -122.404)
        #expect(feature.geometry.latitude == 37.806)
        #expect(feature.geometry.altitude == 95.2)
        #expect(feature.properties.timestamp == 0)
        #expect(feature.properties.speedMetersPerSecond == 0.0)
        #expect(feature.properties.headingDegrees == 0.0)
    }

    @Test func testGeoJSONGeometryParsing() throws {
        let json = """
        {
            "type": "Point",
            "coordinates": [-122.404, 37.806, 95.2]
        }
        """

        let data = json.data(using: .utf8)!
        let geometry = try JSONDecoder().decode(GeoJSONGeometry.self, from: data)

        #expect(geometry.type == "Point")
        #expect(geometry.longitude == -122.404)
        #expect(geometry.latitude == 37.806)
        #expect(geometry.altitude == 95.2)
    }

    @Test func testGeoJSONGeometryParsingWithoutAltitude() throws {
        let json = """
        {
            "type": "Point",
            "coordinates": [-122.404, 37.806]
        }
        """

        let data = json.data(using: .utf8)!
        let geometry = try JSONDecoder().decode(GeoJSONGeometry.self, from: data)

        #expect(geometry.type == "Point")
        #expect(geometry.longitude == -122.404)
        #expect(geometry.latitude == 37.806)
        #expect(geometry.altitude == nil)
    }

    @Test func testGeoJSONGeometryEncoding() throws {
        // Create a GeoJSONGeometry by decoding from JSON first
        let json = """
        {
            "type": "Point",
            "coordinates": [-122.404, 37.806, 95.2]
        }
        """

        let data = json.data(using: .utf8)!
        let geometry = try JSONDecoder().decode(GeoJSONGeometry.self, from: data)

        // Test encoding and re-decoding
        let encodedData = try JSONEncoder().encode(geometry)
        let decoded = try JSONDecoder().decode(GeoJSONGeometry.self, from: encodedData)

        #expect(decoded.type == "Point")
        #expect(decoded.longitude == -122.404)
        #expect(decoded.latitude == 37.806)
        #expect(decoded.altitude == 95.2)
    }

    @Test func testGeoJSONFeaturePropertiesParsing() throws {
        let json = """
        {
            "timestamp": 5,
            "speed_meters_per_second": 11.9,
            "heading_degrees": 210.0
        }
        """

        let data = json.data(using: .utf8)!
        let properties = try JSONDecoder().decode(GeoJSONFeatureProperties.self, from: data)

        #expect(properties.timestamp == 5)
        #expect(properties.speedMetersPerSecond == 11.9)
        #expect(properties.headingDegrees == 210.0)
    }

    @Test func testGeoJSONFeatureParsing() throws {
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

        #expect(feature.type == "Feature")
        #expect(feature.geometry.longitude == -122.404)
        #expect(feature.geometry.latitude == 37.806)
        #expect(feature.geometry.altitude == 95.2)
        #expect(feature.properties.timestamp == 5)
        #expect(feature.properties.speedMetersPerSecond == 11.9)
        #expect(feature.properties.headingDegrees == 210.0)
    }
}
