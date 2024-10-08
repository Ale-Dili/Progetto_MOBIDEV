
import WatchConnectivity
import CoreMotion


class WatchSessionManager: NSObject, ObservableObject, WCSessionDelegate {
    
    static let shared = WatchSessionManager()
    
    private override init() {
        super.init()
        
        // Configura WCSession
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func sendMotionDataToiPhone(accelerometerData: [CMAccelerometerData]) {
        // Verifica se l'iPhone è raggiungibile
        if WCSession.default.isReachable {
            print("Accelerometer data count: \(accelerometerData.count)")
            //print("Gyro data count: \(gyroData.count)")

            
            // Formatta il testo per essere salvato in CSV
            var csvText = "Timestamp,Accelerometer X,Accelerometer Y,Accelerometer Z\n"
            for accelData in  accelerometerData {
                print("entrato")
                let timestamp = "\(accelData.timestamp)"
                let accelerometerX = "\(accelData.acceleration.x)"
                let accelerometerY = "\(accelData.acceleration.y)"
                let accelerometerZ = "\(accelData.acceleration.z)"
                /*
                let gyroX = "\(gyroData.rotationRate.x)"
                let gyroY = "\(gyroData.rotationRate.y)"
                let gyroZ = "\(gyroData.rotationRate.z)"
                 */
                csvText += "\(timestamp),\(accelerometerX),\(accelerometerY),\(accelerometerZ)\n"
            }

            
            print(csvText)
            
            let data: [String: Any] = [
                "csv":  csvText
            ]
            
            print("Dati inviati")
            // Invia i dati all'iPhone
            WCSession.default.sendMessage(data, replyHandler: nil) { error in
                print("Errore nell'invio dei dati: \(error.localizedDescription)")
            }
        } else {
            print("iPhone non raggiungibile")
        }
    }
    
    // Delegate di WCSession
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Errore di attivazione della sessione: \(error.localizedDescription)")
        }
    }
}
