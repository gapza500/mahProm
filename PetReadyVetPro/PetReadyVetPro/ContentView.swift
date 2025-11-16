//
//  ContentView.swift
//  PetReadyVetPro
//
//  Created by - Jhongi on 16/11/2568 BE.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedRole: UserRole = .vet

    enum UserRole: String, CaseIterable {
        case vet = "Vet"
        case clinicAdmin = "Clinic Admin"
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Role Switcher
                Picker("Role", selection: $selectedRole) {
                    ForEach(UserRole.allCases, id: \.self) { role in
                        Text(role.rawValue).tag(role)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                // Content based on selected role
                if selectedRole == .vet {
                    VetView()
                } else {
                    ClinicAdminView()
                }
            }
            .navigationTitle("PetReady VetPro")
            .background(Color.gray.opacity(0.1))
        }
    }
}

struct VetView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Queue Status
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "person.3.fill")
                            .foregroundColor(.blue)
                        Text("Consultation Queue")
                            .font(.headline)
                        Spacer()
                        Text("5 waiting")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 2)
            }
            .padding()
        }
    }
}

struct ClinicAdminView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Clinic Overview
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "building.2.fill")
                            .foregroundColor(.purple)
                        Text("Clinic Overview")
                            .font(.headline)
                        Spacer()
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 2)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
