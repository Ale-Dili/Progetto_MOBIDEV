import SwiftUI

struct ViewGathering: View {
    @StateObject var viewModel = VMGatherAW.viewModel

    var body: some View {
        VStack {
            Text(viewModel.receivedData)
        }
        .onAppear {
            viewModel.setExporterClosure(closure: { fileURL in
                shareFile(url: fileURL)
            })
        }
    }

    func shareFile(url: URL) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            if let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
}

#Preview {
    ContentView()
}
