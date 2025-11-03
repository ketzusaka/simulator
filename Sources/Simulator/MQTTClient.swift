import MQTTNIO
import Foundation
import NIOCore
import NIOFoundationCompat
import NIOPosix

actor MQTTClient: TelemetryPublisher {
    private let mqttClient: MQTTNIO.MQTTClient
    private let brokerHost: String
    private let brokerPort: Int
    private let rid: String
    private let apiToken: String
    
    init(broker: String, rid: String, apiToken: String) async throws {
        self.rid = rid
        self.apiToken = apiToken
        
        // Parse broker URL (e.g., "localhost:1883" or "localhost")
        let components = broker.split(separator: ":")
        self.brokerHost = String(components[0])
        self.brokerPort = components.count > 1 ? Int(components[1]) ?? 1883 : 1883
        
        // Initialize MQTT client
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        self.mqttClient = MQTTNIO.MQTTClient(
            host: brokerHost,
            port: brokerPort,
            identifier: UUID().uuidString,
            eventLoopGroupProvider: .shared(eventLoopGroup),
            logger: nil
        )
        
        // Connect to broker
        try await connect()
    }
    
    private func connect() async throws {
        let connectConfig = MQTTNIO.MQTTClient.ConnectConfiguration(
            keepAliveInterval: TimeAmount.seconds(60),
            userName: rid,
            password: apiToken
        )
        
        _ = try await mqttClient.connect(cleanSession: true, connectConfiguration: connectConfig).get()
        print("✅ Connected to MQTT broker at \(brokerHost):\(brokerPort)")
    }
    
    func sendTelemetry(_ telemetry: TelemetrySample) async throws {
        let topic = "vehicles/\(rid)/telemetry"
        
        do {
            let jsonData = try JSONEncoder().encode(telemetry)
            let payload = ByteBuffer(data: jsonData)
            
            _ = try await mqttClient.publish(
                to: topic,
                payload: payload,
                qos: .atLeastOnce
            ).get()
            
            print("✅ Telemetry published to \(topic) at \(telemetry.ts)")
        } catch {
            throw MQTTError.publishFailed(message: error.localizedDescription)
        }
    }
    
}

enum MQTTError: Error, LocalizedError {
    case connectionFailed(message: String)
    case authenticationFailed
    case publishFailed(message: String)
    case encodingError
    case invalidURL
    
    var errorDescription: String? {
        switch self {
        case .connectionFailed(let message):
            "MQTT connection failed: \(message)"
        case .authenticationFailed:
            "MQTT authentication failed"
        case .publishFailed(let message):
            "MQTT publish failed: \(message)"
        case .encodingError:
            "Failed to encode telemetry data"
        case .invalidURL:
            "Invalid broker URL"
        }
    }
}

