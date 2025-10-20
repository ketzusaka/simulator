import AsyncHTTPClient
import Foundation

actor StrataClient: StrataNetworking {
    private let httpClient: HTTPClient
    private let baseURL: String
    private let apiToken: String

    init(baseURL: String, apiToken: String) {
        self.baseURL = baseURL
        self.apiToken = apiToken
        self.httpClient = HTTPClient(eventLoopGroupProvider: .singleton)
    }

    deinit {
        try? httpClient.syncShutdown()
    }

    func sendTelemetry(_ telemetry: TelemetrySample) async throws {
        let url = "\(baseURL)/telemetry"

        var request = HTTPClientRequest(url: url)
        request.method = .POST
        request.headers.add(name: "Content-Type", value: "application/json")
        request.headers.add(name: "Authorization", value: "Bearer \(apiToken)")

        let jsonData = try JSONEncoder().encode(telemetry)
        request.body = .bytes(jsonData)

        let response = try await httpClient.execute(request, timeout: .seconds(30))

        guard response.status == .accepted else {
            let body = try await response.body.collect(upTo: 1024 * 1024)
            let errorMessage = String(buffer: body)
            throw StrataError.requestFailed(status: Int(response.status.code), message: errorMessage)
        }

        print("✅ Telemetry sent successfully at \(telemetry.ts)")
    }
}

enum StrataError: Error, LocalizedError {
    case requestFailed(status: Int, message: String)
    case invalidURL
    case encodingError

    var errorDescription: String? {
        switch self {
        case .requestFailed(let status, let message):
            "HTTP \(status): \(message)"
        case .invalidURL:
            "Invalid URL"
        case .encodingError:
            "Failed to encode telemetry data"
        }
    }
}
