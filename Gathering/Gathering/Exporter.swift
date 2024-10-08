import Foundation
import Combine

class Exporter: ObservableObject {
    @Published var receivedData: String = "Nessun dato"

    static let exporter = Exporter()

    var shareFile: (URL) -> Void = { _ in }

    func setClosure(closure: @escaping (URL) -> Void) {
        self.shareFile = closure
    }

    func handleReceivedData(data: String) {
        DispatchQueue.main.async {
            self.receivedData = data
        }
        exportData(name: "data.csv", text: data)
    }

    func exportData(name: String, text: String) {
        
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to access document directory")
            return
        }

        let fileURL = documentDirectory.appendingPathComponent(name)
        do {
            try text.write(to: fileURL, atomically: true, encoding: .utf8)
            shareFile(fileURL)
        } catch {
            print("Error writing to CSV file: \(error.localizedDescription)")
        }
    }
}
