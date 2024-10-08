import SwiftUI

struct ViewClassSelection: View {
    
    @State var numClass = 2 // Valore iniziale impostato a 2
    @State var isShowingExtractors = false // Variabile per avviare la navigazione verso le ViewExtractor
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Seleziona il numero di classi")
                .font(.title)
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                .padding(.bottom, 40)
            
            HStack {
                Button(action: {
                    if numClass > 2 {
                        numClass -= 1
                    }
                }) {
                    Text("-")
                        .font(.system(size: 40, weight: .bold))
                        .frame(width: 60, height: 60)
                        .background(numClass > 2 ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(30)
                }
                .disabled(numClass <= 2)
                
                Text("\(numClass)")
                    .font(.largeTitle)
                    .frame(width: 80)
                
                Button(action: {
                    if numClass < 6 {
                        numClass += 1
                    }
                }) {
                    Text("+")
                        .font(.system(size: 40, weight: .bold))
                        .frame(width: 60, height: 60)
                        .background(numClass < 6 ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(30)
                }
                .disabled(numClass >= 6)
            }
            .padding(.vertical, 20)
            
            Spacer()
            
            // NavigationLink to ViewExtractorSequence
            NavigationLink(destination: ViewExtractorSequence(numClass: numClass)) {
                Text("Avanti")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            Spacer()
        }
        .padding()
        
    }
    
}


#Preview {
    ViewClassSelection()
}
