import Foundation

protocol StrataNetworking: Actor {
    func sendTelemetry(_ telemetry: TelemetrySample) async throws
}
