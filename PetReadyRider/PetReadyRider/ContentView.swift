//
//  ContentView.swift
//  PetReadyRider
//
//  Created by - Jhongi on 16/11/2568 BE.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Active Job") {
                    Label("SOS #123 • Pickup in 8 min", systemImage: "bolt.car.fill")
                    Label("Owner chat enabled", systemImage: "bubble.left.and.exclamationmark.bubble.right")
                }

                Section("Available Jobs") {
                    ForEach(0..<3, id: \.self) { idx in
                        NavigationLink("Request #\(idx + 200)", destination: Text("Job details placeholder"))
                    }
                }

                Section("Money Pocket") {
                    Label("Earnings today ฿1,250", systemImage: "creditcard.fill")
                    Label("Withdraw balance", systemImage: "arrow.down.circle")
                }

                Section("Profile & Vehicle") {
                    NavigationLink("Documents", destination: Text("Document uploader placeholder"))
                    NavigationLink("Service areas", destination: Text("Map placeholder"))
                }
            }
            .navigationTitle("Rider Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Go Online") {}
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
