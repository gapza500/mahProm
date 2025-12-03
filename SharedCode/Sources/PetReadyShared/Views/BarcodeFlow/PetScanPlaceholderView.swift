import SwiftUI

#if canImport(UIKit)
import AVFoundation
#endif

public struct PetScanPlaceholderView: View {
    @State private var showInfo = false
    public init() {}

    public var body: some View {
        VStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(style: StrokeStyle(lineWidth: 4, dash: [10]))
                .foregroundColor(.secondary)
                .frame(height: 260)
                .overlay(
                    VStack {
                        Image(systemName: "barcode.viewfinder")
                            .font(.largeTitle)
                        Text("Scanner placeholder")
                            .font(.headline)
                    }
                )
            Button("How scanning works") {
                showInfo = true
            }
            .sheet(isPresented: $showInfo) {
                VStack(spacing: 12) {
                    Text("Scanner Placeholder")
                        .font(.title2)
                        .bold()
                    Text("Implement AVFoundation scanner here once hardware access is ready. For now, use the barcode claim form to simulate registering a pet.")
                        .multilineTextAlignment(.center)
                    Button("Close") { showInfo = false }
                }
                .padding()
            }
        }
        .padding()
        .navigationTitle("Scan Barcode")
    }
}
