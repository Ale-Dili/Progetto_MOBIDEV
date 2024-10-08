import SwiftUI
import CoreMotion

class MotionViewModel: ObservableObject {
    @Published var isRecording = false
    private let motionManager = MotionManager()
    private let watchSessionManager = WatchSessionManager.shared
    
    

    func startRecording() {
        isRecording = true
        motionManager.startRecording()
    }

    func stopRecording() {
        isRecording = false
        motionManager.stopRecording()

        // Send data to iPhone
        let accelerometerData = motionManager.getCollectedData()
        watchSessionManager.sendMotionDataToiPhone(accelerometerData: accelerometerData)
    }
}

