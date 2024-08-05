import AVFoundation

class AudioManager: ObservableObject {
    var audioPlayer: AVAudioPlayer?
    
    func startBackgroundMusic(sound: String, type: String) {
        if let path = Bundle.main.path(forResource: sound, ofType: type) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer?.numberOfLoops = -1 // Endlosschleife
                audioPlayer?.volume = 0.5 // Lautstärke einstellen (0.0 bis 1.0)
                audioPlayer?.play()
            } catch {
                print("Konnte Audio-Datei nicht abspielen.")
            }
        }
    }
    
    func stopBackgroundMusic() {
        audioPlayer?.stop()
    }
}
