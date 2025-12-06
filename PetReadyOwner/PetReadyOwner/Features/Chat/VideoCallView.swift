import SwiftUI
import Combine

struct VideoCallView: View {
    @Environment(\.dismiss) var dismiss
    @State private var time = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
           
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                Image(systemName: "person.fill")
                    .font(.system(size: 150))
                    .foregroundColor(.gray)
                    .padding()
                    .background(Circle().fill(Color.white.opacity(0.2)))
                
                Text("Dr. Expert (Specialist)")
                    .font(.title).bold()
                    .foregroundColor(.white)
                    .padding(.top)
                
                Text(formatTime(time))
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                
                HStack(spacing: 40) {
                    Button {} label: {
                        Image(systemName: "mic.fill")
                            .padding()
                            .background(Circle().fill(Color.white.opacity(0.2)))
                            .foregroundColor(.white)
                    }
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "phone.down.fill")
                            .padding(25)
                            .background(Circle().fill(Color.red))
                            .foregroundColor(.white)
                            .font(.title)
                    }
                    
                    Button {} label: {
                        Image(systemName: "video.fill")
                            .padding()
                            .background(Circle().fill(Color.white.opacity(0.2)))
                            .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .onReceive(timer) { _ in time += 1 }
    }
    
    func formatTime(_ sec: Int) -> String {
        let min = sec / 60
        let s = sec % 60
        return String(format: "%02d:%02d", min, s)
    }
}
