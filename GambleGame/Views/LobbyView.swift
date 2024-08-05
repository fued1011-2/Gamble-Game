import SwiftUI

struct LobbyView: View {
    @ObservedObject var scene: DiceScene
    @State private var showUsernameTextField = false
    @FocusState private var isTextFieldFocused: Bool
    @State private var indexVar: Int = 0

    
    var body: some View {
            VStack {
                HStack {
                    // Back Button
                    Button(action: {
                        scene.gameId = ""
                        scene.leaveGame()
                        scene.currentView = .online
                    }) {
                        Image("back_arrow")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                    }
                    
                    Spacer()
                    
                    Text("ID: \(scene.game.gameId)")
                        .font(.title)
                        .padding(.leading, 20)
                    
                    Spacer().frame(width:95)
                }
                .padding(.leading, 20)
                
                Text("Players")
                    .font(.title)
                
                Spacer()
                
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(Array(scene.game.players.enumerated()), id: \.element.id) { (index: Int, player: Player) in
                            HStack {
                                Text(player.username)
                                    .foregroundColor(.black)
                                
                                if scene.username == player.username {
                                    Button(action: {
                                        if !showUsernameTextField {
                                            withAnimation(.spring()) {
                                                showUsernameTextField.toggle();
                                                if showUsernameTextField {
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                        isTextFieldFocused = true
                                                        indexVar = index
                                                    }
                                                }
                                            }
                                        } else {
                                            scene.changeUsername(index: index, newUsername: scene.username)
                                        }
                                    }) {
                                        Image("pencil")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    }
                                    .frame(width: 29, height: 29)
                                }
                                
                                if scene.username == scene.game.creator.username && scene.username != player.username{
                                    Button(action: {
                                        scene.removePlayerFromOnlineGame(index: index)
                                    }) {
                                        Image("trash-can (1)")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    }
                                    .frame(width: 32, height: 32)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .frame(maxHeight: 400) // Begrenzen Sie die Höhe, falls nötig
                
                TextField("Username", text: $scene.username)
                    .padding()
                    .background(Properties.textFieldColor)
                    .cornerRadius(10)
                    .multilineTextAlignment(.center)
                    .frame(width: 300, height: 35)
                    .offset(y: showUsernameTextField ? -10 : 0)
                    .scaleEffect(showUsernameTextField ? 1 : 0.01, anchor: .top)
                    .opacity(showUsernameTextField ? 1 : 0)
                    .animation(.spring(), value: showUsernameTextField)
                    .onSubmit {
                        if !scene.username.replacingOccurrences(of: " ", with: "").isEmpty {
                            scene.changeUsername(index: indexVar, newUsername: scene.username)
                        }
                    }
                    .focused($isTextFieldFocused)
                    .zIndex(1)
                
                Spacer()
                
                if (scene.username == scene.game.creator.username) {
                    Button(action: {
                        if (scene.username == scene.game.creator.username) {
                            scene.startGame()
                        }
                    }) {
                        Text("Start Game")
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
                    .padding()
                }
            }
        }
}

struct LobbyView_Previews: PreviewProvider {
    static var previews: some View {
        LobbyView(scene: DiceScene())
    }
}
