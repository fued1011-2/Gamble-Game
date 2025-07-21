import SwiftUI

struct MenuView: View {
    @ObservedObject var scene: DiceScene
    @State private var showTextField = false
    @State private var textFieldOrigin: CGFloat = 0
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ZStack {
            VStack {
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 400, height: 400)
                
                VStack(spacing: 40) {
                    Button(action: {
                        scene.username = "Player 1"
                        scene.createLocalGame()
                        scene.currentView = .localLobby
                    }) {
                        Text("Local")
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
                    
                    Button(action: {
                        scene.username = scene.username.replacingOccurrences(of: " ", with: "")
                        if scene.username.replacingOccurrences(of: " ", with: "").isEmpty {
                            withAnimation(.spring()) {
                                showTextField.toggle()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    isTextFieldFocused = true
                                }
                            }
                            textFieldOrigin = 1
                        } else {
                            scene.username = scene.username.replacingOccurrences(of: " ", with: "")
                            scene.isLocalGame = false
                            scene.connect()
                            scene.currentView = .online
                        }
                    }) {
                        Text("Online")
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
                    
                    Button(action: {
                        scene.currentView = .rulesView
                    }) {
                        Text("Rules")
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
                }
                .padding()
                
                Spacer().frame(height: 150)
            }
            .padding(.top, 0)
        }
    }
}
