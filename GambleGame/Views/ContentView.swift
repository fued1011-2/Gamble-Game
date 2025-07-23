import SwiftUI

struct MainView: View {
    @ObservedObject var scene: DiceScene
    @State private var showingLeaveConfirmation = false
    @State private var showPlayerSelectionPopup = false
    @State private var showEndHint = false
    @State private var endHintMessage = ""
    @State private var showRollHint = false
    @State private var rollHintMessage = ""
    @State private var farkleHintMessage = "That’s a Farkle! No points this turn."

    var body: some View {
        ZStack {
            SceneKitView(scene: scene)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ScoreTable(players: scene.isLocalGame ? scene.localGame.players : scene.game.players,
                           currentPlayerIndex: scene.isLocalGame ? scene.localGame.currentPlayerIndex : scene.game.currentPlayerIndex)
                    .padding()
                    .frame(width: 350, height: 125)
                    .background(Color.gray.opacity(0))
                    .cornerRadius(10)
                
                Spacer().frame(height: 450)
                
                Text(scene.isLocalGame ? "\(scene.localGame.roundScore + scene.localGame.throwScore)" : "\(scene.game.roundScore + scene.game.throwScore)")
                    .background(Color.white.opacity(0))
                    .foregroundColor(.black.opacity(scene.isLocalGame ? scene.localGame.roundScore + scene.localGame.throwScore == 0 ? 0.5 : 0.9 : scene.game.roundScore + scene.game.throwScore == 0 ? 0.5 : 0.9))
                    .font(.system(size: 50, weight: .heavy, design: Font.Design.serif))
                    .cornerRadius(10)
                
                Spacer().frame(height: 10)
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        if scene.isLocalGame {
                            if !scene.localGame.thrown {
                                scene.rollDice()
                            } else {
                                if scene.localGame.selectedDice.count != 0 && scene.isValidSelection {
                                    scene.calculateRoundScoreLocal()
                                    scene.rollDice()
                                } else {
                                    if scene.localGame.selectedDice.count != 0 && !scene.isValidSelection {
                                        rollHintMessage = "Only scoring dice can be selected."
                                    } else {
                                        rollHintMessage = "Select at least one scoring die before rolling again."
                                    }
                                    showRollHint = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        showRollHint = false
                                    }
                                }
                            }
                        } else {
                            if (scene.username == scene.game.players[scene.game.currentPlayerIndex].username) {
                                if !scene.game.thrown {
                                    scene.rollDice()
                                } else {
                                    if scene.game.selectedDice.count != 0 && scene.isValidSelection {
                                        scene.calculateRoundScore()
                                        scene.rollDice()
                                    }
                                }
                            }
                        }
                    }) {
                        Text("Roll")
                            .font(.system(size: 50, weight: .heavy, design: Font.Design.serif))
                            .background(Color.clear)
                            .foregroundColor(Color.black.opacity(0.9))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if scene.isLocalGame {
                            print("isLocalGame endRound")
                            if (scene.localGame.roundScore + scene.localGame.throwScore >= 350
                                && !scene.localGame.selectedDice.isEmpty
                                && scene.isValidSelection
                                && scene.localGame.players[scene.localGame.currentPlayerIndex].score + scene.localGame.roundScore + scene.localGame.throwScore == 4200) {
                                showPlayerSelectionPopup = true
                            } else if (scene.localGame.roundScore + scene.localGame.throwScore >= 350
                                       && !scene.localGame.selectedDice.isEmpty
                                       && scene.isValidSelection) {
                                scene.endRoundLocal()
                                scene.turnChangeMessage = "It’s now " + scene.localGame.players[scene.localGame.currentPlayerIndex].username + "'s turn."
                                scene.showTurnChangeHint = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    scene.showTurnChangeHint = false
                                }

                            } else {
                                endHintMessage = "You need at least 350 points before ending a turn."
                                showEndHint = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    showEndHint = false
                                }
                            }
                        } else {
                            if (scene.username == scene.game.players[scene.game.currentPlayerIndex].username) {
                                if (scene.game.roundScore + scene.game.throwScore >= 350
                                    && !scene.game.selectedDice.isEmpty
                                    && scene.isValidSelection 
                                    && scene.game.players[scene.game.currentPlayerIndex].score + scene.game.roundScore + scene.game.throwScore == 4200) {
                                    showPlayerSelectionPopup = true
                                } else if (scene.game.roundScore + scene.game.throwScore >= 350
                                           && !scene.game.selectedDice.isEmpty
                                           && scene.isValidSelection) {
                                    scene.endRound()
                                }
                            }
                        }
                    }) {
                        Text("End")
                            .font(.system(size: 50, weight: .heavy, design: Font.Design.serif))
                            .background(Color.clear)
                            .foregroundColor(.black).opacity(scene.isLocalGame ? (scene.localGame.roundScore + scene.localGame.throwScore >= 350 && !scene.localGame.selectedDice.isEmpty && scene.isValidSelection ? 0.9 : 0.4) : (scene.game.roundScore + scene.game.throwScore >= 350 && !scene.game.selectedDice.isEmpty && scene.isValidSelection ? 0.9 : 0.4))

                    }
                    .sheet(isPresented: $showPlayerSelectionPopup) {
                        PlayerSelectionView(players: scene.game.players.filter { $0.username != scene.username }, onPlayerSelected: { selectedPlayer in
                            scene.deductPointsFromPlayer(selectedPlayer: selectedPlayer)
                            scene.endRound()
                            showPlayerSelectionPopup = false
                        })
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 0)
                
                HStack {
                    Spacer()
                        .frame(width: 178)
                    
                    Button(action: {
                        showingLeaveConfirmation = true
                    }) {
                        Image(systemName: "house.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                            .foregroundColor(.black.opacity(0.8))
                    }
                    
                    Spacer()
                        .frame(width: 95)
                    
                    Button(action: {
                        scene.showRulesView = true
                       }) {
                           Image(systemName: "questionmark.circle")
                               .resizable()
                               .aspectRatio(contentMode: .fit)
                               .frame(width: 50, height: 50)
                               .foregroundColor(.black.opacity(0.8))
                       }
                    
                    Spacer()
                }

            }
            .alert("Final Rounds started", isPresented: $scene.showStartedFinalRoundsPopUp) {
                Button("OK") {
                    scene.showGotKickedPopUp = false
                }
            } message: {
                let playerWith10K = scene.game.players.first(where: {$0.score >= 10000})
                Text("\(String(describing: playerWith10K?.username)) has reached 10000 points. Last Rounds started.")
            }
            .alert(isPresented: $showingLeaveConfirmation) {
                if scene.isLocalGame {
                    Alert(
                        title: Text("Spiel verlassen"),
                        message: Text("Möchten Sie das Spiel wirklich verlassen?"),
                        primaryButton: .destructive(Text("Ja")) {
                            scene.username.removeAll()
                            scene.gameId.removeAll()
                            scene.deleteLocalGame()
                            scene.currentView = .menu
                        },
                        secondaryButton: .cancel(Text("Nein"))
                    )
                } else {
                    Alert(
                        title: Text("Spiel verlassen"),
                        message: Text("Möchten Sie das Spiel wirklich verlassen?"),
                        primaryButton: .destructive(Text("Ja")) {
                            scene.leaveGame()
                            scene.gameId = ""
                            scene.currentView = .menu
                            scene.isLocalGame = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                scene.disconnect()
                            }
                        },
                        secondaryButton: .cancel(Text("Nein"))
                    )
                }
            }
            
            if showEndHint {
                VStack {
                    Spacer()
                        .frame(height: 200)
                    HStack {
                        Spacer()
                        Text(endHintMessage)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 15, weight: .heavy, design: Font.Design.serif))
                            .padding()
                            .foregroundColor(.black)
                            .cornerRadius(10)
                            .transition(.opacity)
                            .animation(.easeInOut, value: showEndHint)
                            .frame(width: 330)
                        Spacer()
                    }
                    .padding(.bottom, 50)
                }
                .zIndex(1) // damit es über Buttons liegt
            }
            
            if showRollHint {
                VStack {
                    Spacer()
                        .frame(height: 200)
                    HStack {
                        Spacer()
                        Text(rollHintMessage)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 15, weight: .heavy, design: .serif))
                            .padding()
                            .foregroundColor(.black)
                            .cornerRadius(10)
                            .transition(.opacity)
                            .animation(.easeInOut, value: showRollHint)
                            .frame(width: 330)
                        Spacer()
                    }
                    .padding(.bottom, 50)
                }
                .zIndex(1)
            }

            if scene.showFarkleHint {
                VStack {
                    Spacer()
                        .frame(height: 200)
                    HStack {
                        Spacer()
                        Text(farkleHintMessage)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 15, weight: .heavy, design: .serif))
                            .padding()
                            .foregroundColor(.black)
                            .cornerRadius(10)
                            .transition(.opacity)
                            .animation(.easeInOut, value: scene.showFarkleHint)
                            .frame(width: 330)
                        Spacer()
                    }
                    .padding(.bottom, 50)
                }
                .zIndex(1)
            }
            
            if scene.showTurnChangeHint {
                VStack {
                    Spacer()
                        .frame(height: 200)
                    HStack {
                        Spacer()
                        Text(scene.turnChangeMessage)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 15, weight: .heavy, design: .serif))
                            .padding()
                            .foregroundColor(.black)
                            .cornerRadius(10)
                            .transition(.opacity)
                            .animation(.easeInOut, value: scene.showTurnChangeHint)
                            .frame(width: 330)
                        Spacer()
                    }
                    .padding(.bottom, 50)
                }
                .zIndex(1)
            }
        }
        .sheet(isPresented: $scene.showRulesView) {
            RulesView(scene: scene)
        }
    }
}

struct ScoreTable: View {
    let players: [Player]
    let currentPlayerIndex: Int
    
    @State private var horizontalScrollViewProxy: ScrollViewProxy?
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Bank")
                .font(.system(size: 30, weight: .heavy, design: Font.Design.serif))
                .background(Color.clear)
                .foregroundColor(Color.black.opacity(0.9))
                .underline()
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(players.indices, id: \.self) { index in
                            VStack {
                                Text(players[index].username)
                                    .font(.system(size: 25, weight: .heavy, design: .serif))
                                    .underline(index == currentPlayerIndex)
                                
                                Text("\(players[index].score)")
                                    .font(.system(size: 20, weight: .bold, design: .serif))
                                    .padding(.top, 3)
                            }
                            .frame(width: 150)
                            .id(index)
                        }
                    }
                }
                .onAppear {
                    horizontalScrollViewProxy = proxy
                    scrollToCurrentPlayer()
                }
            }
        }
        .padding(.top, 10)
        .onChange(of: currentPlayerIndex) { _ in
            scrollToCurrentPlayer()
        }
    }
    
    private func scrollToCurrentPlayer() {
        withAnimation {
            horizontalScrollViewProxy?.scrollTo(currentPlayerIndex, anchor: .leading)
        }
    }
}

struct PlayerSelectionView: View {
    let players: [Player]
    let onPlayerSelected: (Player) -> Void
    
    var body: some View {
        List(players, id: \.username) { player in
            Button(action: {
                onPlayerSelected(player)
            }) {
                Text(player.username)
            }
        }
        .navigationTitle("Select a player to deduct 500 points")
    }
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(scene: DiceScene())
    }
}
