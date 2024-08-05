import SwiftUI

struct RootView: View {
    @ObservedObject var scene = DiceScene()
    @State private var showStartPage = true
    @StateObject private var audioManager = AudioManager()

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors:
                                                [Properties.backgroundColorTop,
                                                 Properties.backgroundColorBottom]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
            
            Image("spray")
                            .resizable()
                            .opacity(0.2)
                            .edgesIgnoringSafeArea(.all)
            
            VStack {
                if showStartPage {
                    StartView()
                        .transition(.opacity)
                } else {
                    switch scene.currentView {
                    case .menu:
                        MenuView(scene: scene)
                            .transition(.opacity)
                    case .online:
                        OnlineView(scene: scene)
                            .transition(.opacity)
                    case .lobby:
                        LobbyView(scene: scene)
                            .transition(.opacity)
                    case .localLobby:
                        LocalLobbyView(scene: scene)
                            .transition(.opacity)
                    case .main:
                        MainView(scene: scene)
                            .transition(.opacity)
                    case .winScreen:
                        WinView(scene: scene)
                            .transition(.opacity)
                    }
                }
            }
            .animation(.easeOut(duration: 0.2))
            .onAppear {
                // Verzögerung für die Startseite
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        self.showStartPage = false
                    }
                }
            }
        }
        .onAppear {
            audioManager.startBackgroundMusic(sound: "backgroundMusic", type: "mp3")
        }
        .onDisappear {
            audioManager.stopBackgroundMusic()
        }

    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
