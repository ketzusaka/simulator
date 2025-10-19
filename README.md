# Skybus Flight Simulator

A Swift CLI application that simulates drone flights by reading GeoJSON flight path files and sending telemetry data to the Strata service in real-time.

## Features

- 🛩️ **Real-time Flight Simulation**: Sends telemetry data at the correct timestamps
- 📍 **GeoJSON Support**: Uses standard GeoJSON format for flight paths
- 🔐 **Authentication**: Supports Vehicle API Token authentication
- ⏱️ **Relative Timestamps**: Uses relative timestamps (seconds from start) for flexible scheduling
- 🚀 **Easy to Use**: Simple CLI interface with clear error messages

## Installation

```bash
cd simulator
swift build
```

## Usage

```bash
swift run Simulator \
  --flight-path examples/sample-flight.geojson \
  --api-token "your-vehicle-api-token" \
  --strata-url "http://localhost:8081" \
  --rid "RID-DRONE-001"
```

### Command Line Arguments

- `--flight-path` (required): Path to the GeoJSON flight path file
- `--api-token` (required): Vehicle API token for authentication
- `--strata-url` (optional): Strata service URL (default: http://localhost:8081)
- `--rid` (required): Remote ID for the simulated vehicle

## Flight Path Format

The simulator uses GeoJSON FeatureCollection format with relative timestamps:

```json
{
  "type": "FeatureCollection",
  "properties": {
    "rid": "RID-DRONE-001",
    "description": "Sample flight path"
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
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [-122.405, 37.807, 100.0]
      },
      "properties": {
        "timestamp": 5,
        "speed_meters_per_second": 11.9,
        "heading_degrees": 210.0
      }
    }
  ]
}
```

### GeoJSON Schema

- **coordinates**: `[longitude, latitude, altitude]` in decimal degrees and meters
- **timestamp**: Seconds from flight start (0 = takeoff)
- **speed_meters_per_second**: Current speed in m/s (optional)
- **heading_degrees**: Direction of travel in degrees (optional)

## Examples

### Simple Flight
```bash
swift run Simulator \
  --flight-path examples/simple-flight.geojson \
  --api-token "your-token" \
  --rid "RID-DRONE-002"
```

### Custom Strata URL
```bash
swift run Simulator \
  --flight-path examples/sample-flight.geojson \
  --api-token "your-token" \
  --strata-url "https://strata.example.com" \
  --rid "RID-DRONE-001"
```

## Development

### Running Tests
```bash
swift test
```

### Building
```bash
swift build
```

### Architecture
- **Actors**: `StrataClient` and `FlightSimulator` are actors for thread-safe concurrency
- **Protocol-Based**: Uses `StrataNetworking` protocol for dependency injection and testing
- **Swift Testing**: Modern testing framework with `#expect` macros
- **Mock Support**: `MockStrataNetworking` for comprehensive testing

### Dependencies
- `swift-argument-parser`: CLI argument parsing
- `async-http-client`: HTTP client for API communication
- `swift-testing`: Modern testing framework (Swift 6.0+)

## Integration with Skybus

The simulator integrates with the Skybus platform:

1. **Strata Service**: Receives telemetry data via HTTP POST to `/telemetry`
2. **Authentication**: Uses Vehicle API Token for authentication
3. **Data Format**: Matches the TelemetrySample schema from Strata API
4. **Real-time Processing**: Data flows through Kafka to Transponder for storage

## Error Handling

The simulator provides clear error messages for common issues:

- **File not found**: Check the flight path file exists
- **Invalid GeoJSON**: Verify the file format is correct
- **Empty flight path**: Ensure the file contains waypoints
- **Authentication failed**: Check the API token is valid
- **Network errors**: Verify the Strata service is running

## License

Part of the Skybus project.
