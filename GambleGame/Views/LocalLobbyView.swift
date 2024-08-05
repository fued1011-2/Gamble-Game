import SwiftUI

struct LocalLobbyView: View {
    @ObservedObject var scene: DiceScene
    @State var newPlayerUsername: String = ""
    @State private var showUsernameTextField = false
    @FocusState private var isTextFieldFocused: Bool
    
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
                            HStack {
                                Text(player.username)
                                    .foregroundColor(.black)
                                    .font(.system(size: 20, weight: .regular, design: .default))
                                    .padding(.top, 5)
                                    .padding(.leading, 35)
                                
                                Button(action: {
                                    if newPlayerUsername.isEmpty {
                                        withAnimation(.spring()) {
                                            showUsernameTextField.toggle();
                                            if showUsernameTextField {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                    isTextFieldFocused = true
                                                }
                                            }
                                        }
                                    } else {
                                        scene.changeUsername(index: index, newUsername: newPlayerUsername)
                                    }
                                }) {
                                    Image("pencil")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                }
                                .frame(width: 29, height: 29)
                                
                                Button(action: {
                                    scene.removePlayerFromLocalGame(index: index)
                                }) {
                                    Image("trash-can (1)")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                }
                                .frame(width: 32, height: 32)
                            }

                        }

                    }
                }
            }
            .frame(maxHeight: 400)
            
            Spacer()
            
            TextField("Username", text: $newPlayerUsername)
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
                    if !newPlayerUsername.replacingOccurrences(of: " ", with: "").isEmpty {
                        scene.addPlayerToLocalGame(username: newPlayerUsername)
                        newPlayerUsername.removeAll()
                    }
                }
                .focused($isTextFieldFocused)
                .zIndex(1)
            
            Button(action: {
                if newPlayerUsername.replacingOccurrences(of: " ", with: "").isEmpty {
                    withAnimation(.spring()) {
                        showUsernameTextField.toggle();
                        if showUsernameTextField {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isTextFieldFocused = true
                            }
                        }
                    }
                } else {
                    scene.addPlayerToLocalGame(username: newPlayerUsername)
                    newPlayerUsername.removeAll()
                }
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
}

struct LocalLobbyView_Previews: PreviewProvider {
    static var previews: some View {
        LocalLobbyView(scene: DiceScene())
    }
}
