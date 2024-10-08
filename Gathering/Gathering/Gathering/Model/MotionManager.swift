//
//  MotionManager.swift
//  Gathering Watch App
//
//  Created by Alessandro  on 18/09/24.
//

import Foundation
import CoreMotion

class MotionManager{
    
    let motionManager = CMMotionManager()
    var accelerometerData: [CMAccelerometerData] = []
    var gyroData: [CMGyroData] = []

    func startRecording() {
        // Clear the arrays before starting recording
        accelerometerData.removeAll()
        gyroData.removeAll()
        
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: .main) { data, error in
            guard let data = data else { return }
            self.accelerometerData.append(data)
        }
        
        if motionManager.isGyroAvailable {
            print("gyro available")
            motionManager.gyroUpdateInterval = 0.1
            motionManager.startGyroUpdates(to: OperationQueue.current!) { data, error in
                guard let data = data, error == nil else {
                    print("Errore raccolta dati giroscopio: \(String(describing: error))")

                    return
                }
                DispatchQueue.main.async {
                    self.gyroData.append(data)
                }
                
            }
        } else {
            print("Giroscopio non disponibile")
        }

    }
    
    func stopRecording() {
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
        
    }
    
    func getCollectedData() ->([CMAccelerometerData],[CMGyroData]){
        return (accelerometerData, gyroData)
    }
    
}
