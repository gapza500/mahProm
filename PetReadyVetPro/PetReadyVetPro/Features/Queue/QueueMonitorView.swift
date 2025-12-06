import SwiftUI

struct QueueMonitorView: View {
    // ข้อมูลจำลอง (คนไข้ที่รออยู่)
    struct QueueItem: Identifiable {
        let id = UUID()
        let ownerName: String
        let petName: String
        let symptom: String
        let waitTime: String
    }
    
    let waitingList = [
        QueueItem(ownerName: "คุณสมศรี", petName: "น้องมอมแมม", symptom: "อาเจียน ไม่กินอาหาร", waitTime: "2 นาที"),
        QueueItem(ownerName: "คุณสมชาย", petName: "เจ้าด่าง", symptom: "ขาเจ็บ เดินกะเผลก", waitTime: "5 นาที")
    ]
    
    var body: some View {
        NavigationStack {
            List(waitingList) { item in
                VStack(alignment: .leading, spacing: 12) {
                    // หัวข้อ
                    HStack {
                        Image(systemName: "pawprint.circle.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                        Text(item.petName)
                            .font(.headline)
                        Text("(\(item.ownerName))")
                            .foregroundColor(.gray)
                        Spacer()
                        Text(item.waitTime)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(6)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    Text("อาการ: \(item.symptom)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    
                    NavigationLink(destination: VetChatView()) {
                        HStack {
                            Spacer()
                            Image(systemName: "video.fill")
                            Text("รับเคส / เริ่มตรวจ (Start Consult)")
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("คิวรอตรวจ (Waiting Queue)")
        }
    }
}

struct QueueMonitorView_Previews: PreviewProvider {
    static var previews: some View {
        QueueMonitorView()
    }
}
