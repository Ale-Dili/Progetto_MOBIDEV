import Foundation

class VMGatherAW: ObservableObject {
    @Published var receivedData: String = "Nessun dato"

    static let viewModel = VMGatherAW()

    private let exporter = Exporter.exporter

    private init() {
        WatchSessionManager.manager.viewModel = self
    }

    func setExporterClosure(closure: @escaping (URL) -> Void) {
        exporter.setClosure(closure: closure)
    }

    func updateReceivedData(_ data: String) {
        DispatchQueue.main.async {
            self.receivedData = data
        }
    }
}
