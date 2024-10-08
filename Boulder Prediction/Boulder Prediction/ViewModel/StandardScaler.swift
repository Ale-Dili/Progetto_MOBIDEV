import Foundation

class StandardScaler {
        
    var trainedMeans = [Double]()
    var trainedStdDevs = [Double]()
    
    init() {
        //LOAD DEVIAZIONE STANDARD
        if let stdDevFile = Bundle.main.url(forResource: "stdDev", withExtension: "txt") {
            do {
                //legge il contenuto, siccome è stringa lo converte
                let stringArray = try String(contentsOf: stdDevFile, encoding: .utf8)

                let cleanedString = stringArray.trimmingCharacters(in: CharacterSet(charactersIn: "[]"))

                let stringValues = cleanedString.components(separatedBy: ",")

                let doubleArray = stringValues.compactMap { Double($0) }

                trainedStdDevs = doubleArray
                
                
            } catch {
                print("Errore nella lettura del file: \(error)")
            }
        } else {
            print("StdDev not found")
        }
        
        //LOAD MEDIA
        if let meanFile = Bundle.main.url(forResource: "means", withExtension: "txt") {
            do {
                //legge il contenuto, siccome è stringa lo converte
                let stringArray = try String(contentsOf: meanFile, encoding: .utf8)

                let cleanedString = stringArray.trimmingCharacters(in: CharacterSet(charactersIn: "[]"))

                let stringValues = cleanedString.components(separatedBy: ",")

                let doubleArray = stringValues.compactMap { Double($0) }

                trainedMeans = doubleArray
                
                
            } catch {
                print("Errore nella lettura del file: \(error)")
            }
        } else {
            print("Means not found")
        }
        
        
        
    }
    
    func scalePredict(value: Double, i: Int) -> Double {
        guard trainedStdDevs[i] != 0 else {
            return 0.0
        }
        
        return (value - trainedMeans[i]) / trainedStdDevs[i]
    }

}
