import SwiftUI

struct ViewRecap: View {
    var csvFilesCollection: [[URL]]
    let vm = ViewModelExtraction.vm
    
    @State var isExtracted = false

    var body: some View {
        ScrollView { // ScrollView verticale principale per l'intera pagina
            VStack(spacing: 20) {
                ForEach(0..<csvFilesCollection.count, id: \.self) { classIndex in
                    VStack(alignment: .leading) {
                        Text("Classe \(classIndex + 1)")
                            .font(.headline)
                            .padding(.bottom, 5)
                        
                        // ScrollView verticale per i file di ogni classe
                        ScrollView {
                            VStack(alignment: .leading) {
                                ForEach(csvFilesCollection[classIndex], id: \.self) { fileURL in
                                    VStack(alignment: .leading) {
                                        Text(fileURL.lastPathComponent)
                                            .font(.subheadline)
                                            .foregroundColor(.blue)
                                        Divider()
                                    }
                                    .onTapGesture {
                                        printCSVContent(fileURL: fileURL)
                                    }
                                }
                            }
                        }
                        .frame(height: 150) // Imposta l'altezza fissa per la lista dei file
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                Button(action: {
                    end()
                }) {
                    Text("Estrai Feature")
                        .font(.headline)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                HStack(){
                    Spacer()
                    Button(action: {
                        vm.exportMeans()
                    }) {
                        Text("Get means")
                            .font(.caption)
                            .padding()
                            .background(isExtracted ? Color.yellow : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    Spacer()
                    Button(action: {
                        vm.exportStdDev()
                    }) {
                        Text("Get stDevs")
                            .font(.caption)
                            .padding()
                            .background(isExtracted ? Color.yellow : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .disabled(!isExtracted)
                    }
                    Spacer()
                }
            }
            
            .padding()
        }.navigationTitle("Riepilogo")
            .onAppear {
                vm.setExporterClosure(closure: { fileURL in
                    shareFile(url: fileURL)
                })
            }
    }
    
    func end(){
        vm.extractAndExport(csvFilesCollection: csvFilesCollection)
        isExtracted = true
    }
    
    
    func shareFile(url: URL) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            if let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
    
    
    // Funzione che legge e stampa il contenuto del file CSV
    func printCSVContent(fileURL: URL) {
        do {
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            print("Contenuto di \(fileURL.lastPathComponent):\n\(content)")
        } catch {
            print("Errore durante la lettura del file CSV: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ViewRecap(csvFilesCollection: [])
}
