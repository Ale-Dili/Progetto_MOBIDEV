//
//  ViewSelectDevice.swift
//  Gathering
//
//  Created by Alessandro  on 27/09/24.
//

import Foundation
import SwiftUI

struct ViewSelectDevice: View {
    var body: some View {
        VStack {
            Text("Seleziona da quale device raccogliere i dati")
                .font(.largeTitle)
                .padding()
                
            
            // Primo bottone per navigare a FirstView
            NavigationLink(destination: ViewGatherIphone()) {
                Text("IPhone")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            // Secondo bottone per navigare a SecondView
            NavigationLink(destination: ViewGathering()) {
                Text("Apple Watch")
                    .font(.headline)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        
    }
}


#Preview {
    ViewSelectDevice()
}
