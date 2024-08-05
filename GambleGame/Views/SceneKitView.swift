import SwiftUI
import SceneKit

struct SceneKitView: UIViewRepresentable {
    var scene: DiceScene
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = scene
        scene.sceneView = scnView  // SceneView im Scene-Objekt setzen
        scnView.allowsCameraControl = false
        scnView.autoenablesDefaultLighting = false
        scene.setSceneView(scnView)
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        // Nichts zu tun
    }
}

struct SceneKitView_Previews: PreviewProvider {
    static var previews: some View {
        SceneKitView(scene: DiceScene())
    }
}
