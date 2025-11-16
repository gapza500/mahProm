//
//  ContentView.swift
//  PetReadyOwner
//
//  Created by - Jhongi on 16/11/2568 BE.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Image(systemName: "pawprint.fill")
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                    Text("PetReady Owner")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding()

                // Pet Status Cards
                ScrollView {
                    VStack(spacing: 16) {
                        // My Pets Card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                                Text("My Pets")
                                    .font(.headline)
                                Spacer()
                                Text("3")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }

                            HStack(spacing: 12) {
                                ForEach(0..<3) { index in
                                    VStack {
                                        Circle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 60, height: 60)
                                            .overlay(
                                                Image(systemName: "pawprint")
                                                    .foregroundColor(.white)
                                            )
                                        Text("Pet \(index + 1)")
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 2)

                        // Quick Actions
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Quick Actions")
                                .font(.headline)

                            HStack(spacing: 12) {
                                Button(action: {}) {
                                    VStack {
                                        Image(systemName: "cross.fill")
                                            .font(.title2)
                                            .foregroundColor(.red)
                                        Text("Vet Chat")
                                            .font(.caption)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())

                                Button(action: {}) {
                                    VStack {
                                        Image(systemName: "location.fill")
                                            .font(.title2)
                                            .foregroundColor(.green)
                                        Text("Find Clinic")
                                            .font(.caption)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())

                                Button(action: {}) {
                                    VStack {
                                        Image(systemName: "star.fill")
                                            .font(.title2)
                                            .foregroundColor(.yellow)
                                        Text("Health")
                                            .font(.caption)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                    .padding()
                }

                Spacer()
            }
            .background(Color.gray.opacity(0.1))
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    ContentView()
}
