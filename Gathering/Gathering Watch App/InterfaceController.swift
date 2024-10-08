import WatchKit
import Foundation
import WatchConnectivity
import CoreMotion

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    let motionManager = CMMotionManager()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Inizializza la sessione WCSession
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    @IBAction func startSendingData() {
        // Verifica che il dispositivo iPhone sia raggiungibile
        if WCSession.default.isReachable {
            // Avvia la raccolta dati da accelerometro e giroscopio
            startMotionUpdates()
        }
    }

    func startMotionUpdates() {
        if motionManager.isAccelerometerAvailable && motionManager.isGyroAvailable {
            motionManager.accelerometerUpdateInterval = 1.0 / 50.0
            motionManager.gyroUpdateInterval = 1.0 / 50.0
            
            motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data, error) in
                if let accelerometerData = data {
                    let accelX = accelerometerData.acceleration.x
                    let accelY = accelerometerData.acceleration.y
                    let accelZ = accelerometerData.acceleration.z
                    
                    // Invia i dati dell'accelerometro all'iPhone
                    self.sendDataToiPhone(accelData: [accelX, accelY, accelZ])
                }
            }

            motionManager.startGyroUpdates(to: OperationQueue.current!) { (data, error) in
                if let gyroData = data {
                    let gyroX = gyroData.rotationRate.x
                    let gyroY = gyroData.rotationRate.y
                    let gyroZ = gyroData.rotationRate.z
                    
                    // Invia i dati del giroscopio all'iPhone
                    self.sendDataToiPhone(gyroData: [gyroX, gyroY, gyroZ])
                }
            }
        }
    }

    func sendDataToiPhone(accelData: [Double]? = nil, gyroData: [Double]? = nil) {
        var data: [String: Any] = [:]
        
        if let accelData = accelData {
            data["accelerometer"] = accelData
        }
        
        if let gyroData = gyroData {
            data["gyroscope"] = gyroData
        }
        
        // Invia i dati all'iPhone
        WCSession.default.sendMessage(data, replyHandler: nil, errorHandler: { error in
            print("Errore nell'invio dei dati: \(error.localizedDescription)")
        })
    }

    // Delegate di WCSession
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Errore di attivazione della sessione: \(error.localizedDescription)")
        }
    }
}
