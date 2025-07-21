import SwiftUI

struct LocalLobbyView: View {
    @ObservedObject var scene: DiceScene
    @State private var showUsernameTextField = false
    @FocusState private var isTextFieldFocused: Bool
    @State private var editingIndex: Int? = nil
    @State private var newPlayerUsername: String = ""
    let nameFieldWidth: CGFloat = 220
    
    var body: some View {
        VStack {
            HStack {
                // Back Button
                Button(action: {
                    scene.deleteLocalGame()
                    scene.currentView = .menu
                }) {
                    Image("back_arrow")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                }
                
                Spacer()
                
                Text("Players")
                    .font(.title)
                
                Spacer().frame(width: 155)
            }
            .padding(.leading, 20)
            
            Spacer()
            
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(Array(scene.localGame.players.enumerated()), id: \.element.id) { (index: Int, player: Player) in
                        VStack {
                            ZStack {
                                // Nur der Name ist zentriert im Bildschirm
                                HStack {
                                    
                                    Spacer()

                                    let isEditingThisPlayer = editingIndex == index

                                    Group {
                                        if isEditingThisPlayer {
                                            TextField("", text: $newPlayerUsername, onCommit: {
                                                scene.changeUsername(index: index, newUsername: newPlayerUsername)
                                                editingIndex = nil
                                            })
                                            .focused($isTextFieldFocused)
                                            .multilineTextAlignment(.center)
                                            .onSubmit {
                                                    saveAndExit()
                                                }
                                            .onChange(of: isTextFieldFocused) { focused in
                                                    if !focused {
                                                        saveAndExit()
                                                    }
                                                }
                                        } else {
                                            Text(player.username)
                                                .multilineTextAlignment(.center)
                                        }
                                    }
                                    .foregroundColor(.black)
                                    .font(.system(size: 20, weight: .regular, design: .default))
                                    .padding(.top, 5)

                                    Spacer()
                                }

                                // Buttons rechts neben dem zentrierten Namen
                                HStack(spacing: 12) {
                                    let isEditingThisPlayer = editingIndex == index
                                    
                                    Spacer() // schiebt Buttons ganz nach rechts relativ zum Zentrum

                                    Button(action: {
                                        if isEditingThisPlayer {
                                            if !newPlayerUsername.isEmpty {
                                                scene.changeUsername(index: index, newUsername: newPlayerUsername)
                                            }
                                            editingIndex = nil
                                        } else {
                                            newPlayerUsername = player.username
                                            withAnimation(.spring()) {
                                                editingIndex = index
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                    isTextFieldFocused = true
                                                }
                                            }
                                        }
                                    }) {
                                        Image("pencil")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    }
                                    .frame(width: 29, height: 29)

                                    Button(action: {
                                        scene.removePlayerFromLocalGame(index: index)
                                        scene.localGamePlayerCount -= 1
                                    }) {
                                        Image("trash-can (1)")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    }
                                    .frame(width: 32, height: 32)
                                }
                                .padding(.top, 5)
                            }
                        }
                    }
                }
            }
            .frame(maxHeight: 400)
            
            Spacer()
            
            Button(action: {
                scene.addPlayerToLocalGame(username: "Player \(scene.localGamePlayerCount + 1)")
                scene.localGamePlayerCount += 1
            }) {
                Text("Add Player")
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
            .zIndex(0)
            
            Button(action: {
                scene.currentView = .main
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
    
    func saveAndExit() {
        if let index = editingIndex, !newPlayerUsername.isEmpty {
            scene.changeUsername(index: index, newUsername: newPlayerUsername)
        }
        editingIndex = nil
    }
}

struct LocalLobbyView_Previews: PreviewProvider {
    static var previews: some View {
        LocalLobbyView(scene: DiceScene())
    }
}
