import SwiftUI

struct WinView: View {
    @ObservedObject var scene = DiceScene()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Herzlichen Glückwunsch!")
                .font(.largeTitle)
                .padding()
            
            Text("\(scene.winnerName) hat gewonnen!")
                .font(.title)
                .padding()
            
            Button(action: {
                scene.leaveGame()
                scene.currentView = .menu
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    scene.disconnect()
                }
            }) {
                Text("Zurück zum Menü")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

struct WinView_Previews: PreviewProvider {
    static var previews: some View {
        WinView()
    }
}
