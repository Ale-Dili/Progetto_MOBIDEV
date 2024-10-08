import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Benvenuto!")
                    .font(.largeTitle)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .padding()
                
                // Primo bottone per navigare a FirstView
                NavigationLink(destination: ViewSelectDevice()) {
                    Text("Gathering")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()

                // Secondo bottone per navigare a SecondView
                NavigationLink(destination: ViewClassSelection()) {
                    Text("Extractor")
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
}


#Preview {
    ContentView()
}
