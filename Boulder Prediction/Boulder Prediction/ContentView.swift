//
//  ViewGatherIphone.swift
//  Gathering
//
//  Created by Alessandro  on 27/09/24.
//



import Foundation
import SwiftUI

struct ContentView: View {
    
    @StateObject var viewModel = VM.viewModel
    
    var body: some View {
        VStack {
    
            Text(viewModel.isRecording ? "Recording..." : "Not Recording")
                .bold()
            Button(viewModel.isRecording ? "Stop" : "Start") {
                if viewModel.isRecording {
                    viewModel.stopRecording()
                } else {
                    viewModel.startRecording()
                }
            }
            
            .frame(height: 60.0)
            .frame(width: 120.0)
            .background(viewModel.isRecording ? Color.red : Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.bottom, 200)
            Text(viewModel.predictedLabel)
                .bold()
    
            Rectangle()
                .fill(viewModel.predictedColor)
                .frame(width: 100.0, height: 100.0)
                .cornerRadius(10)
                
            
            
        }
    }
    

}


#Preview {
    ContentView()
}
