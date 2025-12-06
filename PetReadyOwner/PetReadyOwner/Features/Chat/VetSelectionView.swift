import SwiftUI

struct VetSelectionView: View {
    var body: some View {
        List {
            NavigationLink(destination: OwnerChatView()) {
                HStack {
                    Image(systemName: "person.circle.fill").font(.largeTitle).foregroundColor(.green)
                    VStack(alignment: .leading) {
                        Text("Dr. Somchai").font(.headline)
                        Text("General Vet • Online").font(.caption).foregroundColor(.gray)
                    }
                    Spacer()
                    Text("฿300").bold().foregroundColor(.blue)
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("เลือกสัตวแพทย์")
    }
}
