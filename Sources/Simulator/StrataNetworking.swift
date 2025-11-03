import Foundation

protocol TelemetryPublisher: Actor {
    func sendTelemetry(_ telemetry: TelemetrySample) async throws
}
