import Foundation

// MARK: - GeoJSON Models

struct GeoJSONFeatureCollection: Codable {
    let type: String
    let properties: GeoJSONProperties?
    let features: [GeoJSONFeature]
    
    enum CodingKeys: String, CodingKey {
        case type, properties, features
    }
}

struct GeoJSONProperties: Codable {
    let rid: String?
    let description: String?
}

struct GeoJSONFeature: Codable {
    let type: String
    let geometry: GeoJSONGeometry
    let properties: GeoJSONFeatureProperties
}

struct GeoJSONGeometry: Codable {
    let type: String
    let longitude: Double
    let latitude: Double
    let altitude: Double?
    
    enum CodingKeys: String, CodingKey {
        case type, coordinates
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        
        let coordinates = try container.decode([Double].self, forKey: .coordinates)
        guard coordinates.count >= 2 else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Coordinates must have at least longitude and latitude")
            )
        }
        
        longitude = coordinates[0]
        latitude = coordinates[1]
        altitude = coordinates.count > 2 ? coordinates[2] : nil
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        
        if let altitude = altitude {
            try container.encode([longitude, latitude, altitude], forKey: .coordinates)
        } else {
            try container.encode([longitude, latitude], forKey: .coordinates)
        }
    }
}

struct GeoJSONFeatureProperties: Codable {
    let timestamp: Double // seconds from start
    let speedMetersPerSecond: Double?
    let headingDegrees: Double?
    
    enum CodingKeys: String, CodingKey {
        case timestamp
        case speedMetersPerSecond = "speed_meters_per_second"
        case headingDegrees = "heading_degrees"
    }
}
