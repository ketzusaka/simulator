import Foundation
@testable import Simulator

actor MockTelemetryPublisher: TelemetryPublisher {
    private var _sendTelemetryInvocatedParameters: [TelemetrySample] = []
    private var _stubSendTelemetry: (TelemetrySample) async throws -> Void = { _ in }

    // Public access to invocated parameters
    var sendTelemetryInvocatedParameters: [TelemetrySample] {
        get async {
            _sendTelemetryInvocatedParameters
        }
    }

    // Function to set the stub
    func setStubSendTelemetry(_ stub: @escaping (TelemetrySample) async throws -> Void) {
        _stubSendTelemetry = stub
    }

    // Function to reset the mock
    func reset() {
        _sendTelemetryInvocatedParameters = []
        _stubSendTelemetry = { _ in }
    }

    func sendTelemetry(_ telemetry: TelemetrySample) async throws {
        // Record the parameters
        _sendTelemetryInvocatedParameters.append(telemetry)

        // Call the stub
        try await _stubSendTelemetry(telemetry)
    }
}
