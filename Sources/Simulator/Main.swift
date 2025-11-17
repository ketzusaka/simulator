import ArgumentParser
import Foundation

@main
struct SimulatorCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "simulator",
        abstract: "Simulate drone flights by sending telemetry data via MQTT",
        discussion: """
        The Simulator CLI reads GeoJSON flight path files and publishes telemetry data
        to an MQTT broker in real-time, respecting the relative timestamps
        in the flight path data.
        """
    )

    @Argument(help: "Path to the GeoJSON flight path file")
    var flightPath: String

    @Option(name: .shortAndLong, help: "Vehicle API token for authentication")
    var apiToken: String

    @Option(name: .shortAndLong, help: "MQTT broker URL (default: localhost:1883)")
    var mqttBroker: String = "localhost:1883"

    @Option(name: .shortAndLong, help: "Remote ID for the simulated vehicle")
    var rid: String

    func run() async throws {
        print("🚁 Skybus Flight Simulator")
        print("==========================")
        print("Flight Path: \(flightPath)")
        print("MQTT Broker: \(mqttBroker)")
        print("Remote ID: \(rid)")
        print("")

        // Validate inputs
        guard !apiToken.isEmpty else {
            throw ValidationError("API token cannot be empty")
        }

        guard !rid.isEmpty else {
            throw ValidationError("Remote ID cannot be empty")
        }

        // Initialize components
        print("Initializing MQTT client...")
        let mqttClient = try await MQTTClient(broker: mqttBroker, rid: rid, apiToken: apiToken)
        print("🔌 Connecting to MQTT broker…")
        do {
            try await mqttClient.connect()
            print("✅ MQTT client connected")
        } catch {
            print("❌ MQTT connection failed:", String(reflecting: error))
            await mqttClient.shutdown()
            throw ExitCode.failure
        }

        print("MQTT client initialized. Initializing flight simulator...")
        let flightSimulator = FlightSimulator(telemetryPublisher: mqttClient, rid: rid)
        print("Flight simulator initialized")

        do {
            print("Simulating flight...")
            try await flightSimulator.simulateFlight(from: flightPath)
            print("Flight simulation completed")
        } catch {
            print("❌ Simulation failed: \(error.localizedDescription)")
            throw ExitCode.failure
        }
        await mqttClient.shutdown()
    }
}
