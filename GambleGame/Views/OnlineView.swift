import SwiftUI

struct OnlineView: View {
    @ObservedObject var scene: DiceScene
    @State private var showGameIDField = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack {
            HStack {
                // Back Button
                Button(action: {
                    scene.disconnect()
                    scene.currentView = .menu
                    scene.isLocalGame = true
                }) {
                    Image("back_arrow")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                }
                
                Spacer()
            }
            .padding(.top, 80)
            .padding(.leading, 20)
            
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 400, height: 400)
                .padding(.top, 10)
            
            VStack(spacing: 10) {
                
                Button(action: {
                    scene.createGame()
                    scene.currentView = .lobby
                }) {
                    Text("Create Game")
                        .font(.title)
                        .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 35)
                        .padding()
                        .background(Properties.buttonColor)
                        .foregroundColor(Color.black)
                        .shadow(color: Properties.buttonShadowColor, radius: Properties.buttonShadowRadius, x: Properties.buttonShadowX, y: Properties.buttonShadowY)
                        .cornerRadius(Properties.buttonCornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Properties.buttonBorderColor, lineWidth: Properties.buttonBorderLineWidth)
                        )
                }
                .frame(width: 220, height: 50)
                .shadow(color: Properties.buttonShadowColor, radius: Properties.buttonShadowRadius, x: Properties.buttonShadowX, y: Properties.buttonShadowY)
                
                
                ZStack(alignment: .top) {
                    Button(action: {
                        if scene.gameId.isEmpty {
                            withAnimation(.spring()) {
                                showGameIDField.toggle();
                                if showGameIDField {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        isTextFieldFocused = true
                                    }
                                }
                            }
                        } else {
                            scene.checkIfGameExists(gameId: scene.gameId)
                        }
                    }) {
                        Text("Join Game")
                            .font(.title)
                            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 35)
                            .padding()
                            .background(Properties.buttonColor)
                            .foregroundColor(Color.black)
                            .shadow(color: Properties.buttonShadowColor, radius: Properties.buttonShadowRadius, x: Properties.buttonShadowX, y: Properties.buttonShadowY)
                            .cornerRadius(Properties.buttonCornerRadius)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Properties.buttonBorderColor, lineWidth: Properties.buttonBorderLineWidth)
                            )
                    }
                    .frame(width: 220, height: 50)
                    .shadow(color: Properties.buttonShadowColor, radius: Properties.buttonShadowRadius, x: Properties.buttonShadowX, y: Properties.buttonShadowY)
                    .zIndex(1)
                    
                    TextField("Game ID", text: $scene.gameId)
                        .padding()
                        .background(Properties.textFieldColor)
                        .multilineTextAlignment(.center)
                        .cornerRadius(10)
                        .frame(width: 300, height: 35)
                        .offset(y: showGameIDField ? 80 : 0)
                        .scaleEffect(showGameIDField ? 1 : 0.01, anchor: .top)
                        .opacity(showGameIDField ? 1 : 0)
                        .animation(.spring(), value: showGameIDField)
                        .onSubmit {
                            scene.checkIfGameExists(gameId: scene.gameId)
                        }
                        .focused($isTextFieldFocused)
                        .zIndex(0)
                }
                .frame(height: 110)
                
                Spacer().frame(height: 220)
            }
            .padding(.top, 0)
        }
        .alert("You've been kicked", isPresented: $scene.showGotKickedPopUp) {
            Button("OK") {
                scene.showGotKickedPopUp = false
            }
        } message: {
            Text("You have been removed from the game.")
        }
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.currentIndex = hex.startIndex
        
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let red = Double((rgbValue & 0xff0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00ff00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000ff) / 255.0
        
        print(red)
        print(red)
        print(red)
        
        self.init(red: red, green: green, blue: blue)
    }
}
