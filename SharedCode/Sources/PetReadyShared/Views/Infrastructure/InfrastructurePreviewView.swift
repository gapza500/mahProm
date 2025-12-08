import SwiftUI

@MainActor
public struct InfrastructurePreviewView: View {
    private let locationService: LocationServiceProtocol
    private let pushService: PushNotificationServiceProtocol
    private let realtimeService: RealtimeSyncServiceProtocol

    @State private var route: [LocationSnapshot] = []
    @State private var liveSnapshot: LocationSnapshot?
    @State private var liveEvents: [LiveEvent] = []
    @State private var permissionState: PushPermissionState
    @State private var locationStatus: String

    public init(
        locationService: LocationServiceProtocol = LocationService(),
        pushService: PushNotificationServiceProtocol? = nil,
        realtimeService: RealtimeSyncServiceProtocol = RealtimeSyncService()
    ) {
        let resolvedPushService = pushService ?? PushNotificationService()

        self.locationService = locationService
        self.pushService = resolvedPushService
        self.realtimeService = realtimeService
        _permissionState = State(initialValue: resolvedPushService.permissionState)
        _locationStatus = State(initialValue: locationService.authorizationStatusDescription)
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                infrastructureCard(title: "Live GPS", icon: "location.circle.fill") {
                    let snapshot = liveSnapshot ?? locationService.latestSnapshot()
                    VStack(alignment: .leading, spacing: 8) {
                        Text(snapshot.title)
                            .font(.headline)
                        Text(snapshot.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("Lat: \(String(format: "%.4f", snapshot.coordinate.latitude)), Lon: \(String(format: "%.4f", snapshot.coordinate.longitude))")
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                        Text("Status: \(locationStatus)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Divider()
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mock Route")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        ForEach(route) { stop in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "point.topleft.down.curvedto.point.bottomright.up")
                                    .font(.caption)
                                    .foregroundStyle(Color(red: 0.63, green: 0.73, blue: 0.95))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(stop.title).font(.subheadline.weight(.semibold))
                                    Text(stop.subtitle).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }

                infrastructureCard(title: "Realtime Sync", icon: "bolt.horizontal.circle.fill") {
                    if liveEvents.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(liveEvents) { event in
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "sparkles")
                                        .font(.caption)
                                        .foregroundStyle(Color(red: 0.97, green: 0.44, blue: 0.64))
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(event.description)
                                            .font(.subheadline.weight(.medium))
                                        Text(event.timestamp, style: .time)
                                            .font(.caption2.monospacedDigit())
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }

                infrastructureCard(title: "Push Notifications", icon: "bell.badge.fill") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Permission State")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Label(permissionDescription, systemImage: permissionIcon)
                            .font(.headline)
                            .foregroundStyle(permissionColor)
                        Text("We'll swap this stub out for UNUserNotificationCenter once backend endpoints are ready.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Button(action: requestPushPermission) {
                            HStack(spacing: 8) {
                                Image(systemName: "hand.tap.fill")
                                Text("Simulate Request")
                                    .font(.subheadline.weight(.semibold))
                            }
                            .foregroundStyle(DesignSystem.Colors.onAccentText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(permissionColor, in: RoundedRectangle(cornerRadius: 14))
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Base Infrastructure")
        .task {
            route = locationService.requestMockRoute()
            await startRealtimeDemo()
        }
        .task {
            locationService.requestAuthorizationIfNeeded()
            for await snapshot in locationService.locationUpdates() {
                await MainActor.run {
                    self.liveSnapshot = snapshot
                    self.locationStatus = locationService.authorizationStatusDescription
                }
            }
        }
    }

    private func requestPushPermission() {
        Task {
            await pushService.requestPermission()
            await MainActor.run {
                permissionState = pushService.permissionState
            }
        }
    }

    private func startRealtimeDemo() async {
        let stream = await realtimeService.subscribe(to: "demo-channel")
        for await event in stream {
            await MainActor.run {
                liveEvents.append(event)
            }
        }
    }

    @ViewBuilder
    private func infrastructureCard<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(Color(red: 0.97, green: 0.44, blue: 0.64))
                Text(title)
                    .font(.title3.bold())
            }
            content()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 12, y: 6)
    }

    private var permissionDescription: String {
        switch permissionState {
        case .notDetermined:
            return "Waiting for user choice"
        case .granted:
            return "Ready to send notifications"
        case .denied:
            return "User denied permissions"
        }
    }

    private var permissionIcon: String {
        switch permissionState {
        case .notDetermined:
            return "questionmark.circle"
        case .granted:
            return "checkmark.circle"
        case .denied:
            return "xmark.circle"
        }
    }

    private var permissionColor: Color {
        switch permissionState {
        case .notDetermined:
            return Color(red: 0.98, green: 0.74, blue: 0.35)
        case .granted:
            return Color(red: 0.37, green: 0.66, blue: 0.54)
        case .denied:
            return Color(red: 0.87, green: 0.32, blue: 0.37)
        }
    }
}
