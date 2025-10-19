import Foundation
import ArgumentParser

@main
struct SimulatorCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "simulator",
        abstract: "Simulate drone flights by sending telemetry data to Strata",
        discussion: """
        The Simulator CLI reads GeoJSON flight path files and sends telemetry data
        to the Strata service in real-time, respecting the relative timestamps
        in the flight path data.
        """
    )
    
    @Argument(help: "Path to the GeoJSON flight path file")
    var flightPath: String
    
    @Option(name: .shortAndLong, help: "Vehicle API token for authentication")
    var apiToken: String
    
    @Option(name: .shortAndLong, help: "Strata service URL (default: http://localhost:8081)")
    var strataURL: String = "http://localhost:8081"
    
    @Option(name: .shortAndLong, help: "Remote ID for the simulated vehicle")
    var rid: String
    
    func run() async throws {
        print("🚁 Skybus Flight Simulator")
        print("==========================")
        print("Flight Path: \(flightPath)")
        print("Strata URL: \(strataURL)")
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
        let strataClient = StrataClient(baseURL: strataURL, apiToken: apiToken)
        let flightSimulator = FlightSimulator(strataNetworking: strataClient, rid: rid)
        
        do {
            try await flightSimulator.simulateFlight(from: flightPath)
        } catch {
            print("❌ Simulation failed: \(error.localizedDescription)")
            throw ExitCode.failure
        }
    }
}
