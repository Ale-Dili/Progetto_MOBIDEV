import Foundation
import SwiftUI

struct ViewExtractorSequence: View {
    var numClass: Int
    @State private var currentClass = 1
    @State private var csvFilesCollection: [[URL]] = []
    @State private var isCompleted = false
    
    var body: some View {
        if isCompleted {
            ViewRecap(csvFilesCollection: csvFilesCollection)
        } else {
            // Passa un array vuoto alla nuova ViewExtractor per non mostrare i file selezionati precedentemente
            ViewExtractor(
                classNumber: currentClass,
                onCompletion: { csvFiles in
                    csvFilesCollection.append(csvFiles)
                    if currentClass < numClass {
                        currentClass += 1
                    } else {
                        isCompleted = true
                    }
                }
            )
        }
    }
}

