import Foundation

public protocol AppointmentServiceProtocol {
    func upcomingAppointments() async throws -> [Appointment]
}

public final class AppointmentService: AppointmentServiceProtocol {
    private let apiClient: APIClientProtocol

    public init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    public func upcomingAppointments() async throws -> [Appointment] {
        try await apiClient.request(Endpoint(path: "appointments"), response: [Appointment].self)
    }
}
