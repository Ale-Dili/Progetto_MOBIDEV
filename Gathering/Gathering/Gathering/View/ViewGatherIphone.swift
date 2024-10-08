//
//  ViewGatherIphone.swift
//  Gathering
//
//  Created by Alessandro  on 27/09/24.
//



import Foundation
import SwiftUI

struct ViewGatherIphone: View {
    
    @StateObject var viewModel = VMGatherIphone.viewModel
    
    var body: some View {
        VStack {
            
            Text(viewModel.isRecording ? "Recording..." : "Not Recording")
            
            Button(viewModel.isRecording ? "Stop" : "Start") {
                if viewModel.isRecording {
                    viewModel.stopRecording()
                } else {
                    viewModel.startRecording()
                }
            }
            .padding()
            .background(viewModel.isRecording ? Color.red : Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            
        }        .onAppear {
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
    ViewGatherIphone()
}
