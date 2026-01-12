//
//  APIClient.swift
//  BD Assistant
//
//  Central API client for communicating with the FastAPI backend
//

import Foundation

// MARK: - API Errors
enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, message: String?)
    case decodingError(Error)
    case networkError(Error)
    case unauthorized
    case serverError(String)
    case offline

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid server URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code, let message):
            return message ?? "HTTP error: \(code)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized - please reconnect"
        case .serverError(let message):
            return "Server error: \(message)"
        case .offline:
            return "No network connection"
        }
    }
}

// MARK: - API Client
actor APIClient {
    static let shared = APIClient()

    private var baseURL: String = ""
    private var apiKey: String?
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.waitsForConnectivity = true

        self.session = URLSession(configuration: config)

        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // Try multiple date formats
            let formats = [
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ",
                "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
                "yyyy-MM-dd'T'HH:mm:ssZ",
                "yyyy-MM-dd'T'HH:mm:ss",
                "yyyy-MM-dd"
            ]

            for format in formats {
                let formatter = DateFormatter()
                formatter.dateFormat = format
                formatter.locale = Locale(identifier: "en_US_POSIX")
                if let date = formatter.date(from: dateString) {
                    return date
                }
            }

            // Try ISO8601 as fallback
            if let date = ISO8601DateFormatter().date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date: \(dateString)")
        }

        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
    }

    // MARK: - Configuration
    func configure(baseURL: String, apiKey: String? = nil) {
        self.baseURL = baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        self.apiKey = apiKey
    }

    // MARK: - Health Check
    func healthCheck() async throws -> HealthCheckResponse {
        return try await request(endpoint: "/health", method: "GET")
    }

    // MARK: - Dashboard
    func getDashboardMetrics() async throws -> DashboardMetrics {
        return try await request(endpoint: "/api/dashboard/metrics", method: "GET")
    }

    func getDailyRoutine() async throws -> DailyRoutine {
        return try await request(endpoint: "/api/orchestrator/daily-routine", method: "GET")
    }

    func getAgents() async throws -> [AgentInfo] {
        return try await request(endpoint: "/api/agents", method: "GET")
    }

    // MARK: - Leads
    func getLeads(status: LeadStatus? = nil, score: LeadScore? = nil, limit: Int = 50) async throws -> [Lead] {
        var queryItems: [URLQueryItem] = [URLQueryItem(name: "limit", value: String(limit))]

        if let status = status {
            queryItems.append(URLQueryItem(name: "status", value: status.rawValue))
        }
        if let score = score {
            queryItems.append(URLQueryItem(name: "score", value: score.rawValue))
        }

        return try await request(endpoint: "/api/leads", method: "GET", queryItems: queryItems)
    }

    func getLead(id: String) async throws -> Lead {
        return try await request(endpoint: "/api/leads/\(id)", method: "GET")
    }

    func createLead(_ lead: Lead) async throws -> Lead {
        return try await request(endpoint: "/api/leads", method: "POST", body: lead)
    }

    func updateLead(_ lead: Lead) async throws -> Lead {
        return try await request(endpoint: "/api/leads/\(lead.id)", method: "PUT", body: lead)
    }

    func deleteLead(id: String) async throws {
        let _: EmptyResponse = try await request(endpoint: "/api/leads/\(id)", method: "DELETE")
    }

    func qualifyLead(_ request: LeadQualificationRequest) async throws -> LeadQualificationResponse {
        return try await self.request(endpoint: "/api/lead-gen/qualify", method: "POST", body: request)
    }

    func enrichLead(id: String) async throws -> Lead {
        return try await request(endpoint: "/api/lead-gen/enrich/\(id)", method: "POST")
    }

    // MARK: - Proposals
    func getProposals(leadId: String? = nil, status: ProposalStatus? = nil) async throws -> [Proposal] {
        var queryItems: [URLQueryItem] = []

        if let leadId = leadId {
            queryItems.append(URLQueryItem(name: "lead_id", value: leadId))
        }
        if let status = status {
            queryItems.append(URLQueryItem(name: "status", value: status.rawValue))
        }

        return try await request(endpoint: "/api/proposals", method: "GET", queryItems: queryItems)
    }

    func getProposal(id: String) async throws -> Proposal {
        return try await request(endpoint: "/api/proposals/\(id)", method: "GET")
    }

    func generateProposal(_ request: ProposalGenerationRequest) async throws -> Proposal {
        return try await self.request(endpoint: "/api/content/generate-proposal", method: "POST", body: request)
    }

    func updateProposal(_ proposal: Proposal) async throws -> Proposal {
        return try await request(endpoint: "/api/proposals/\(proposal.id)", method: "PUT", body: proposal)
    }

    func sendProposal(id: String) async throws -> Proposal {
        return try await request(endpoint: "/api/proposals/\(id)/send", method: "POST")
    }

    // MARK: - Research & Intelligence
    func getIntelligenceBriefs(type: BriefType? = nil, unreadOnly: Bool = false) async throws -> [IntelligenceBrief] {
        var queryItems: [URLQueryItem] = []

        if let type = type {
            queryItems.append(URLQueryItem(name: "type", value: type.rawValue))
        }
        if unreadOnly {
            queryItems.append(URLQueryItem(name: "unread_only", value: "true"))
        }

        return try await request(endpoint: "/api/research/briefs", method: "GET", queryItems: queryItems)
    }

    func generateDailyBrief() async throws -> IntelligenceBrief {
        return try await request(endpoint: "/api/research/daily-brief", method: "POST")
    }

    func markBriefAsRead(id: String) async throws {
        let _: EmptyResponse = try await request(endpoint: "/api/research/briefs/\(id)/read", method: "POST")
    }

    func conductMarketResearch(_ request: MarketResearchRequest) async throws -> MarketResearchResponse {
        return try await self.request(endpoint: "/api/research/market-analysis", method: "POST", body: request)
    }

    // MARK: - Analytics
    func getPipelineAnalytics() async throws -> PipelineAnalytics {
        return try await request(endpoint: "/api/analytics/pipeline", method: "GET")
    }

    // MARK: - Voice Notes
    func transcribeVoiceNote(audioData: Data) async throws -> String {
        // This would use a speech-to-text endpoint
        let transcription: TranscriptionResponse = try await uploadData(
            endpoint: "/api/voice/transcribe",
            data: audioData,
            mimeType: "audio/m4a"
        )
        return transcription.text
    }

    // MARK: - Private Request Methods
    private func request<T: Decodable>(
        endpoint: String,
        method: String,
        queryItems: [URLQueryItem] = [],
        body: (any Encodable)? = nil
    ) async throws -> T {
        guard var urlComponents = URLComponents(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        if !queryItems.isEmpty {
            urlComponents.queryItems = queryItems
        }

        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let apiKey = apiKey {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            request.httpBody = try encoder.encode(body)
        }

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            switch httpResponse.statusCode {
            case 200...299:
                do {
                    return try decoder.decode(T.self, from: data)
                } catch {
                    throw APIError.decodingError(error)
                }
            case 401:
                throw APIError.unauthorized
            case 400...499:
                let message = String(data: data, encoding: .utf8)
                throw APIError.httpError(statusCode: httpResponse.statusCode, message: message)
            case 500...599:
                let message = String(data: data, encoding: .utf8) ?? "Internal server error"
                throw APIError.serverError(message)
            default:
                throw APIError.httpError(statusCode: httpResponse.statusCode, message: nil)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    private func uploadData<T: Decodable>(
        endpoint: String,
        data: Data,
        mimeType: String
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        if let apiKey = apiKey {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"audio.m4a\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        let (responseData, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }

        return try decoder.decode(T.self, from: responseData)
    }
}

// MARK: - Helper Types
struct EmptyResponse: Decodable {}

struct TranscriptionResponse: Decodable {
    let text: String
}

// MARK: - Network Monitor
import Network

@MainActor
class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    @Published var isConnected = true
    @Published var connectionType: ConnectionType = .unknown

    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isConnected = path.status == .satisfied

                if path.usesInterfaceType(.wifi) {
                    self?.connectionType = .wifi
                } else if path.usesInterfaceType(.cellular) {
                    self?.connectionType = .cellular
                } else if path.usesInterfaceType(.wiredEthernet) {
                    self?.connectionType = .ethernet
                } else {
                    self?.connectionType = .unknown
                }
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
