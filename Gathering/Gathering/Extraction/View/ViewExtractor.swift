import SwiftUI
import UniformTypeIdentifiers

struct ViewExtractor: View {
    let classNumber: Int
    let onCompletion: ([URL]) -> Void
    
    @State private var csvFiles: [URL] = [] // Questa variabile sarà sempre locale e resettata ogni volta
    @State private var showDocumentPicker = false
    
    var body: some View {
        VStack {
            Text("Seleziona i file CSV per la classe \(classNumber)")
                .font(.title)
                .padding()
            
            Button(action: {
                showDocumentPicker = true
            }) {
                Text("Seleziona file CSV")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            List(csvFiles, id: \.self) { file in
                Text(file.lastPathComponent)
            }
            
            Button(action: {
                onCompletion(csvFiles)
            }) {
                Text("Prossima classe")
                    .font(.headline)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .fileImporter(
            isPresented: $showDocumentPicker,
            allowedContentTypes: [.commaSeparatedText],
            allowsMultipleSelection: true,
            onCompletion: handleFileSelection
        )
    }
    
    func handleFileSelection(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            csvFiles = []
            for url in urls {
                if url.startAccessingSecurityScopedResource() {
                    defer { url.stopAccessingSecurityScopedResource() }
                    
                    do {
                        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let destinationURL = documentDirectory.appendingPathComponent(url.lastPathComponent)
                        
                        if !FileManager.default.fileExists(atPath: destinationURL.path) {
                            try FileManager.default.copyItem(at: url, to: destinationURL)
                        }
                        csvFiles.append(destinationURL)
                    } catch {
                        print("Errore durante la copia del file: \(error.localizedDescription)")
                    }
                } else {
                    print("Impossibile accedere al file: \(url.lastPathComponent)")
                }
            }
        case .failure(let error):
            print("Errore nella selezione dei file: \(error.localizedDescription)")
        }
    }
}





