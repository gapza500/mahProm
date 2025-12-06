import SwiftUI
import Combine

struct VideoCallView: View {
    @Environment(\.dismiss) var dismiss
    @State private var second = 0
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
    
            Color.black.ignoresSafeArea()
            
            VStack {
                Spacer()
                
              
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 150))
                    .foregroundColor(.gray)
                    .padding()
                    .background(Circle().fill(Color.white.opacity(0.1)))
                
              
                Text("กำลังติดต่อเจ้าของ")
                    .font(.title).bold()
                    .foregroundColor(.white)
                    .padding(.top)
                
              
                Text(formatTime(second))
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
               
                HStack(spacing: 40) {
                    CircleButton(icon: "mic.slash.fill", color: .white.opacity(0.2)) // ปิดไมค์
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "phone.down.fill")
                            .font(.largeTitle)
                            .padding(30)
                            .background(Color.red)
                            .clipShape(Circle())
                            .foregroundColor(.white)
                    }
                    
                    CircleButton(icon: "video.fill", color: .white.opacity(0.2))
                }
                .padding(.bottom, 60)
            }
        }
        .onReceive(timer) { _ in second += 1 }
    }
    
  
    func formatTime(_ sec: Int) -> String {
        let min = sec / 60
        let s = sec % 60
        return String(format: "%02d:%02d", min, s)
    }
    

    func CircleButton(icon: String, color: Color) -> some View {
        Image(systemName: icon)
            .font(.title)
            .padding(20)
            .background(color)
            .clipShape(Circle())
            .foregroundColor(.white)
    }
}
