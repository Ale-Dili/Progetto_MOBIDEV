import Foundation


struct Signal{
    
    var samples: [Sample]
    
    init() {
        self.samples = [Sample]()
    }
    
    mutating func addSample(s: Sample){
        samples.append(s)
    }
    
    
    func head(n: Int = 5) {
        let limit = min(n, samples.count)
        for i in 0..<limit {
            print("Sample \(i + 1): \(samples[i].toString())")
        }
    }
    
    func getColumn(name: String) -> [Double] {
        switch name {
        case "accelerometerX":
            return samples.map { $0.accelerometerX }
        case "accelerometerY":
            return samples.map { $0.accelerometerY }
        case "accelerometerZ":
            return samples.map { $0.accelerometerZ }
        case "gyroX":
            return samples.map { $0.gyroX }
        case "gyroY":
            return samples.map { $0.gyroY }
        case "gyroZ":
            return samples.map { $0.gyroZ }
        default:
            return [] // Ritorna un array vuoto se il nome non corrisponde a nessuna colonna
        }
    }
    
}
