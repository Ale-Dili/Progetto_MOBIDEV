//
//  ViewModelGatheringIphone.swift
//  Gathering
//
//  Created by Alessandro  on 27/09/24.
//

import Foundation
import CoreMotion


class VMGatherIphone: ObservableObject {
    @Published var isRecording = false
    private let motionManager = MotionManager()
    
    private let exporter = Exporter.exporter
    
    static let viewModel = VMGatherIphone()
    
    private init() {
    }
    
    func setExporterClosure(closure: @escaping (URL) -> Void) {
        exporter.setClosure(closure: closure)
    }

    func startRecording() {
        isRecording = true
        motionManager.startRecording()
    }

    func stopRecording() {
        isRecording = false
        motionManager.stopRecording()
        
        let (accelerometerData , gyroData) = motionManager.getCollectedData()

        var csvText = "Timestamp,Accelerometer X,Accelerometer Y,Accelerometer Z,Gyro X,Gyro Y,Gyro Z\n"
        for (accelData, gyroData) in zip(accelerometerData, gyroData) {
            let timestamp = "\(accelData.timestamp)"
            let accelerometerX = "\(accelData.acceleration.x)"
            let accelerometerY = "\(accelData.acceleration.y)"
            let accelerometerZ = "\(accelData.acceleration.z)"
            let gyroX = "\(gyroData.rotationRate.x)"
            let gyroY = "\(gyroData.rotationRate.y)"
            let gyroZ = "\(gyroData.rotationRate.z)"
            csvText += "\(timestamp),\(accelerometerX),\(accelerometerY),\(accelerometerZ),\(gyroX),\(gyroY),\(gyroZ)\n"
        }
        
        exporter.exportData(name: "data.csv", text: csvText)
    }
}
