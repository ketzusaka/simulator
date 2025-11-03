# Skybus Flight Simulator

A Swift CLI application that simulates drone flights by reading GeoJSON flight path files and publishing telemetry data to an MQTT broker in real-time.

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
  --mqtt-broker "localhost:1883" \
  --rid "RID-DRONE-001"
```

### Command Line Arguments

- `--flight-path` (required): Path to the GeoJSON flight path file
- `--api-token` (required): Vehicle API token for authentication
- `--mqtt-broker` (optional): MQTT broker URL (default: localhost:1883)
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

### Custom MQTT Broker
```bash
swift run Simulator \
  --flight-path examples/sample-flight.geojson \
  --api-token "your-token" \
  --mqtt-broker "mqtt.example.com:8883" \
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
- **Actors**: `MQTTClient` and `FlightSimulator` are actors for thread-safe concurrency
- **Protocol-Based**: Uses `TelemetryPublisher` protocol for dependency injection and testing
- **Swift Testing**: Modern testing framework with `#expect` macros
- **Mock Support**: `MockTelemetryPublisher` for comprehensive testing

### Code Quality

This project uses SwiftLint for code quality and style enforcement.

#### SwiftLint Setup

```bash
# Install SwiftLint (if not already installed)
brew install swiftlint

# Run linting
make lint

# Auto-fix violations where possible
make lint-fix
```

#### SwiftLint Configuration

The project includes a `.swiftlint.yml` configuration that enforces:
- **Modern Swift patterns**: Implicit returns, functional programming style
- **Code style**: Consistent formatting, import sorting, spacing
- **Best practices**: Access control, type inference, error handling

SwiftLint diagnostics will appear in Cursor's Problems panel and guide AI-assisted code generation.

### Dependencies
- `swift-argument-parser`: CLI argument parsing
- `mqtt-nio`: MQTT client for broker communication
- `swift-testing`: Modern testing framework (Swift 6.0+)

## Integration with Skybus

The simulator integrates with the Skybus platform:

1. **MQTT Broker (EMQX)**: Publishes telemetry data to `vehicles/{rid}/telemetry` topic
2. **Authentication**: Uses Vehicle API Token for authentication (username=rid, password=token)
3. **Data Format**: JSON telemetry matching TelemetrySample schema
4. **Real-time Processing**: Data flows MQTT → Link → Kafka → Transponder for storage

## Error Handling

The simulator provides clear error messages for common issues:

- **File not found**: Check the flight path file exists
- **Invalid GeoJSON**: Verify the file format is correct
- **Empty flight path**: Ensure the file contains waypoints
- **Authentication failed**: Check the API token is valid
- **Connection errors**: Verify the MQTT broker is running and accessible
- **Publish failures**: Check MQTT broker configuration and permissions

## License

Part of the Skybus project.
