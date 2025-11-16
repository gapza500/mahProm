//
//  ContentView.swift
//  PetReadyCentralAdmin
//
//  Created by - Jhongi on 16/11/2568 BE.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("System Overview") {
                    Label("Active SOS cases: 2", systemImage: "exclamationmark.triangle.fill")
                    Label("Online vets: 45 • riders: 28", systemImage: "waveform.path.ecg")
                }

                Section("Approvals") {
                    NavigationLink("3 vet verifications pending", destination: Text("Vet approvals placeholder"))
                    NavigationLink("5 rider registrations pending", destination: Text("Rider approvals placeholder"))
                }

                Section("Announcements") {
                    NavigationLink("Create public alert", destination: Text("Announcement composer"))
                    NavigationLink("Scheduled posts", destination: Text("Content calendar"))
                }

                Section("Analytics & Monitoring") {
                    Label("Service uptime 99.9%", systemImage: "gauge.medium")
                    Label("Average chat SLA 7m", systemImage: "timer.circle.fill")
                }
            }
            .navigationTitle("Central Admin")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Broadcast") {}
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
