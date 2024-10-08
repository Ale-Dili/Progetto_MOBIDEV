import Foundation

struct Sample{
    var accelerometerX: Double
    var accelerometerY: Double
    var accelerometerZ: Double
    var gyroX: Double
    var gyroY: Double
    var gyroZ: Double
    
    init(_ accelerometerX: Double,_ accelerometerY: Double,_ accelerometerZ: Double,_ gyroX: Double,_ gyroY: Double,_ gyroZ: Double) {
        self.accelerometerX = accelerometerX
        self.accelerometerY = accelerometerY
        self.accelerometerZ = accelerometerZ
        self.gyroX = gyroX
        self.gyroY = gyroY
        self.gyroZ = gyroZ
    }
    
    func toString() -> String{
        return "Accelerometer - X: \(accelerometerX), Y: \(accelerometerY), Z: \(accelerometerZ)\n" +
                "Gyroscope - X: \(gyroX), Y: \(gyroY), Z: \(gyroZ)"
            
    }
}
