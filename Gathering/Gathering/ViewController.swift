import UIKit
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configura WCSession
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    // Delegate per ricevere i messaggi dal Watch
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Ricevi i dati dell'accelerometro
        if let accelerometerData = message["accelerometer"] as? [Double] {
            print("Dati Accelerometro ricevuti: \(accelerometerData)")
            // Puoi elaborare i dati qui
        }
        
        // Ricevi i dati del giroscopio
        if let gyroscopeData = message["gyroscope"] as? [Double] {
            print("Dati Giroscopio ricevuti: \(gyroscopeData)")
            // Puoi elaborare i dati qui
        }
    }
    
    // Delegate di attivazione della sessione
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Errore di attivazione della sessione: \(error.localizedDescription)")
        }
    }
}
