import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MotionViewModel()

    var body: some View {
        VStack {
            
            Text(viewModel.isRecording ? "Recording..." : "Not Recording")
            
            Button(viewModel.isRecording ? "Stop" : "Start") {
                if viewModel.isRecording {
                    viewModel.stopRecording()
                } else {
                    viewModel.startRecording()
                }
            }
            .padding()
            .background(viewModel.isRecording ? Color.red : Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}



#Preview {
    ContentView()
}
