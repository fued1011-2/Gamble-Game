import SceneKit
import Combine
import AVFoundation

class DiceScene: SCNScene, ObservableObject, SCNPhysicsContactDelegate {
    let dice1IntitalPosition = SCNVector3(x: 3, y: 10, z: -2)
    let dice2IntitalPosition = SCNVector3(x: -3, y: 10, z: -2)
    let dice3IntitalPosition = SCNVector3(x: 0, y: 10, z: -2)
    let dice4IntitalPosition = SCNVector3(x: 3, y: 10, z: 2)
    let dice5IntitalPosition = SCNVector3(x: -3, y: 10, z: 2)
    let dice6IntitalPosition = SCNVector3(x: 0, y: 10, z: 2)
    
    let dice1Name = "Dice1"
    let dice2Name = "Dice2"
    let dice3Name = "Dice3"
    let dice4Name = "Dice4"
    let dice5Name = "Dice5"
    let dice6Name = "Dice6"
    
    var sceneView: SCNView?
    
    @Published var diceValues: [DiceValue] = []
    @Published var isLocalGame: Bool = true
    @Published var localGame: LocalGameState
    @Published var localGamePlayerCount: Int = 1
    var localGameController: LocalGameController
    var diceNodes: [SCNNode] = []
    var selectedDiceNodes: Set<SCNNode> = Set()
    var selectedDiceNodesArray: [SCNNode] = []
    var takenDiceNodes: Set<SCNNode> = Set(minimumCapacity: 6)
    var dicePositionsAfterThrow: [SCNNode: SCNVector3] = [:]
    var tapped: Bool = false
    
    @Published var game: GameState
    @Published var username: String = ""
    @Published var gameId: String = ""
    @Published var winnerName: String = ""
    @Published var isValidSelection: Bool = false
    var isThrownDiceValid: Bool = false
    @Published var currentView: ViewType = .menu
    @Published var showGotKickedPopUp: Bool = false
    @Published var showStartedFinalRoundsPopUp: Bool = false
    private var gameClient: GameClient
    
    override init() {
        self.game = GameState(gameId: "0",
                              thrownDiceValues: [],
                              selectedDice: [],
                              takenDice: [],
                              diceRotations: [],
                              roundScore: 0,
                              throwScore: 0,
                              thrown: false,
                              win: false,
                              players: [],
                              disconnectedPlayers: [],
                              currentPlayerIndex: 0,
                              creator: Player(),
                              isLastRound: false,
                              lastRoundCounter: 0,
                              winnerIndex: -1)
        self.localGame = LocalGameState(gameId: "0",
                                        thrownDiceValues: [],
                                        selectedDice: [],
                                        takenDice: [],
                                        diceRotations: [],
                                        roundScore: 0,
                                        throwScore: 0,
                                        thrown: false,
                                        win: false,
                                        players: [],
                                        currentPlayerIndex: 0,
                                        isLastRound: false,
                                        lastRoundCounter: 0,
                                        winnerIndex: -1)
        self.gameClient = GameClient()
        self.localGameController = LocalGameController()
        super.init()
        self.gameClient.delegate = self
        setupScene()
        setupTapGestureRecognizer()
    }
    
    required init?(coder: NSCoder) {
        self.game = GameState(gameId: "0",
                              thrownDiceValues: [],
                              selectedDice: [],
                              takenDice: [],
                              diceRotations: [],
                              roundScore: 0,
                              throwScore: 0,
                              thrown: false,
                              win: false,
                              players: [],
                              disconnectedPlayers: [],
                              currentPlayerIndex: 0,
                              creator: Player(),
                              isLastRound: false,
                              lastRoundCounter: 0,
                              winnerIndex: -1)
        self.localGame = LocalGameState(gameId: "0",
                                        thrownDiceValues: [],
                                        selectedDice: [],
                                        takenDice: [],
                                        diceRotations: [],
                                        roundScore: 0,
                                        throwScore: 0,
                                        thrown: false,
                                        win: false,
                                        players: [],
                                        currentPlayerIndex: 0,
                                        isLastRound: false,
                                        lastRoundCounter: 0,
                                        winnerIndex: -1)
        self.gameClient = GameClient()
        self.localGameController = LocalGameController()
        super.init(coder: coder)
        self.gameClient.delegate = self
        setupScene()
        setupTapGestureRecognizer()
    }
    
    private func setupScene() {
        // Kontakt-Delegat setzen
        physicsWorld.contactDelegate = self
        
        // Hauptlichtquelle (Umgebungslicht)
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = 1000
        ambientLight.color = UIColor(white: 0.8, alpha: 1.0)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight
        rootNode.addChildNode(ambientLightNode)
        
        // Tischlampe simulieren
        let lampLight = SCNLight()
        lampLight.type = .spot
        lampLight.castsShadow = true
        lampLight.shadowMode = .deferred
        lampLight.shadowColor = UIColor.black.withAlphaComponent(0.4)
        lampLight.shadowRadius = 5
        lampLight.intensity = 1000
        lampLight.spotInnerAngle = 80
        lampLight.spotOuterAngle = 110
        lampLight.attenuationStartDistance = 5
        lampLight.attenuationEndDistance = 20
        lampLight.color = UIColor(red: 1.0, green: 0.95, blue: 0.8, alpha: 1.0)  // Weißes Licht
        
        let lampLightNode = SCNNode()
        lampLightNode.light = lampLight
        lampLightNode.position = SCNVector3(x: -4, y: 13, z: -6)  // Direkt über dem Container
        lampLightNode.eulerAngles = SCNVector3(x: -(Float.pi / 1.7), y:Float.pi / 3, z: 0)  // Nach unten gerichtet
        rootNode.addChildNode(lampLightNode)
        
        // Kamera hinzufügen
        let camera = SCNCamera()
        camera.zNear = 0.1
        camera.zFar = 100
        camera.fieldOfView = 68 // Angepasstes Sichtfeld
        
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: 20, z: 5) // Direkt von oben
        cameraNode.eulerAngles = SCNVector3(-Float.pi / 2.4, 0, 0) // Nach unten gerichtet
        rootNode.addChildNode(cameraNode)
        
        // Würfel mit Texturen hinzufügen
        addDiceNode(position: SCNVector3(x: -3.7, y: 0.5, z: 0))
        addDiceNode(position: SCNVector3(x: -2.2, y: 0.5, z: 0))
        addDiceNode(position: SCNVector3(x: -0.7, y: 0.5, z: 0))
        addDiceNode(position: SCNVector3(x: 0.8, y: 0.5, z: 0))
        addDiceNode(position: SCNVector3(x: 2.3, y: 0.5, z: 0))
        addDiceNode(position: SCNVector3(x: 3.8, y: 0.5, z: 0))
        
        // Boden hinzufügen
        let floor = SCNBox(width: 50, height: 0.1, length: 50, chamferRadius: 0)
        let floorMaterial = SCNMaterial()
        // Holztextur hinzufügen (falls vorhanden)
        if let woodTexture = UIImage(named: "wood_floor_texture") {
            floorMaterial.diffuse.contents = woodTexture
        }
        floorMaterial.lightingModel = .physicallyBased
        floorMaterial.roughness.contents = 0.8
        floorMaterial.metalness.contents = 1.0
        floor.materials = [floorMaterial]
        
        let floorNode = SCNNode(geometry: floor)
        floorNode.position = SCNVector3(x: 0, y: 0, z: 0)
        floorNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        floorNode.physicsBody?.categoryBitMask = 0b0010
        floorNode.physicsBody?.contactTestBitMask = 0b0100
        floorNode.physicsBody?.collisionBitMask = 0b1111
        floorNode.name = "floor"
        rootNode.addChildNode(floorNode)
        
        // Behälter hinzufügen
        let container = createContainer()
        rootNode.addChildNode(container)
    }
    
    private func setupTapGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView?.addGestureRecognizer(tapGesture)
        sceneView?.isUserInteractionEnabled = true
    }
    
    private func addDiceNode(position: SCNVector3) {
        let dice = createTexturedDice()
        let diceNode = SCNNode(geometry: dice)
        diceNode.position = position
        
        // Erstellen Sie einen zusammengesetzten Physikkörper für den Würfel
        let shape = SCNPhysicsShape(
            shapes: [SCNPhysicsShape(geometry: dice, options: nil)],
            transforms: nil
        )
        diceNode.physicsBody = SCNPhysicsBody(type: .static, shape: shape)
        diceNode.physicsBody?.mass = 1.0
        diceNode.physicsBody?.restitution = 0.5
        diceNode.physicsBody?.friction = 0.5
        diceNode.physicsBody?.categoryBitMask = 0b0001
        diceNode.physicsBody?.contactTestBitMask = 0b0010
        diceNode.physicsBody?.collisionBitMask = 0b1111
        
        // Tap-Gesten-Erkenner hinzufügen
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView?.addGestureRecognizer(tapGestureRecognizer)
        
        rootNode.addChildNode(diceNode)
        diceNodes.append(diceNode)
        
        for (index, diceNode) in diceNodes.enumerated() {
            switch index {
            case 0: diceNode.name = dice1Name
            case 1: diceNode.name = dice2Name
            case 2: diceNode.name = dice3Name
            case 3: diceNode.name = dice4Name
            case 4: diceNode.name = dice5Name
            case 5: diceNode.name = dice6Name
            default: break
            }
        }
    }
    
    func setSceneView(_ view: SCNView) {
        self.sceneView = view
        setupTapGestureRecognizer()
    }
    
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        print("Tap detected")  // Debug print
        let location = gestureRecognize.location(in: sceneView)
        let hitResults = sceneView?.hitTest(location, options: [SCNHitTestOption.searchMode: SCNHitTestSearchMode.closest.rawValue])
        
        if let result = hitResults?.first {
            let node = result.node
            if !takenDiceNodes.contains(node) && isLocalGame ? localGame.thrown : game.thrown {
                if ((node.physicsBody?.isResting) == true || tapped == true) {
                    if let index = diceNodes.firstIndex(of: node),
                       let diceValue = diceValues[safe: index]?.value {
                        if isLocalGame {
                            localDiceSelected(index: index, value: diceValue)
                        } else {
                            if username == game.players[game.currentPlayerIndex].username {
                                gameClient.diceSelected(gameId: game.gameId, index: index, value: diceValue)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func toggleDiceSelected(index: Int) {
        let diceNode = diceNodes[index]
        if selectedDiceNodes.contains(diceNode) {
            selectedDiceNodes.remove(diceNode)
            selectedDiceNodesArray.removeAll(where: { $0 === diceNode})
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 1.0
            
            // Bewege den Würfel zur Position nach dem Arrangieren
            if let originalPosition = dicePositionsAfterThrow[diceNode] {
                diceNode.position = originalPosition
            }
            
            SCNTransaction.commit()
            print("Dice unselected")
        } else {
            selectedDiceNodes.insert(diceNode)
            selectedDiceNodesArray.append(diceNode)
            print("Dice selected")
        }
        arrangeSelectedDice()
    }
    
    private func createTexturedDice() -> SCNBox {
        let dice = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.05)
        
        func createMaterial(imageName: String) -> SCNMaterial {
            let material = SCNMaterial()
            
            // Basis-Textur (Diffuse)
            material.diffuse.contents = UIImage(named: imageName)
            
            // Physikalisch basiertes Rendering
            material.lightingModel = .physicallyBased
            
            // Erhöhte Rauigkeit für weniger Spiegelung
            material.roughness.contents = 0.8
            
            // Reduzierte Metallizität
            material.metalness.contents = 0.0
            
            // Reduzierte Spiegelung
            material.specular.contents = UIColor.white
            material.specular.intensity = 0.1
            
            // Leichte Emission für einen subtilen Glanz (optional)
            material.emission.contents = UIColor(white: 0.05, alpha: 1.0)
            
            return material
        }
        
        dice.materials = [
            createMaterial(imageName: "dice_one"),
            createMaterial(imageName: "dice_two"),
            createMaterial(imageName: "dice_three"),
            createMaterial(imageName: "dice_four"),
            createMaterial(imageName: "dice_five"),
            createMaterial(imageName: "dice_six")
        ]
        
        return dice
    }
    
    func resetDicePositionsAfterThrow() {
        dicePositionsAfterThrow.removeAll()
    }
    
    private func createContainer() -> SCNNode {
        let thickness: CGFloat = 0.2
        let width: CGFloat = 10.0
        let visibleHeight: CGFloat = 1.0
        let invisibleHeight: CGFloat = 9.0 // Zusätzliche Höhe für unsichtbare Wände
        let outerHeight: CGFloat = 1.25 // Höhe der äußeren Wände
        let outerHeight2: CGFloat = 1.75 // Höhe der 2. äußeren Wände
        let frontThickness: CGFloat = 1.6
        
        // Boden des Behälters
        let bottom = SCNBox(width: width, height: thickness, length: width, chamferRadius: 0)
        let bottomNode = SCNNode(geometry: bottom)
        bottomNode.position = SCNVector3(0, 0, 0)
        
        // Dunkelgrünes, filzähnliches Material für den Boden
        let bottomMaterial = SCNMaterial()
        bottomMaterial.diffuse.contents = UIImage(named: "red_teppich")
        bottomMaterial.roughness.contents = 1.0
        bottomMaterial.metalness.contents = 0.0
        bottom.materials = [bottomMaterial]
        
        bottomNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        bottomNode.physicsBody?.categoryBitMask = 0b0010
        bottomNode.physicsBody?.contactTestBitMask = 0b0100
        bottomNode.physicsBody?.collisionBitMask = 0b1111
        
        // Funktion zum Erstellen einer sichtbaren schwarzen Wand
        func createVisibleWall(width: CGFloat, height: CGFloat, length: CGFloat) -> SCNNode {
            let wall = SCNBox(width: width, height: height, length: length, chamferRadius: 0)
            let wallNode = SCNNode(geometry: wall)
            
            let reflectiveMaterial = SCNMaterial()
            reflectiveMaterial.diffuse.contents = UIColor.black
            reflectiveMaterial.specular.contents = UIColor.white
            reflectiveMaterial.shininess = 100.0
            reflectiveMaterial.reflective.contents = UIColor(white: 1.0, alpha: 0.3)
            reflectiveMaterial.lightingModel = .physicallyBased
            reflectiveMaterial.roughness.contents = 0.9
            
            wall.materials = [reflectiveMaterial]
            
            wallNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
            wallNode.physicsBody?.categoryBitMask = 0b0010
            wallNode.physicsBody?.contactTestBitMask = 0b0100
            wallNode.physicsBody?.collisionBitMask = 0b1111
            
            return wallNode
        }
        
        // Funktion zum Erstellen einer unsichtbaren Wand
        func createInvisibleWall(width: CGFloat, height: CGFloat, length: CGFloat) -> SCNNode {
            let wall = SCNBox(width: width, height: height, length: length, chamferRadius: 0)
            let wallNode = SCNNode(geometry: wall)
            
            wall.materials = [SCNMaterial()]
            wall.materials.first?.diffuse.contents = UIColor.clear
            
            wallNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
            wallNode.physicsBody?.categoryBitMask = 0b0010
            wallNode.physicsBody?.contactTestBitMask = 0b0100
            wallNode.physicsBody?.collisionBitMask = 0b1111
            
            wallNode.opacity = 0.0
            
            return wallNode
        }
        
        // Sichtbare Wände des Behälters
        let leftVisibleWall = createVisibleWall(width: thickness, height: visibleHeight, length: width)
        leftVisibleWall.position = SCNVector3(-width / 2 + thickness / 2, visibleHeight / 2, 0)
        
        let rightVisibleWall = createVisibleWall(width: thickness, height: visibleHeight, length: width)
        rightVisibleWall.position = SCNVector3(width / 2 - thickness / 2, visibleHeight / 2, 0)
        
        let frontVisibleWall = createVisibleWall(width: width, height: visibleHeight, length: thickness)
        frontVisibleWall.position = SCNVector3(0, visibleHeight / 2, -width / 2 + thickness / 2)
        
        let backVisibleWall = createVisibleWall(width: width, height: visibleHeight, length: thickness)
        backVisibleWall.position = SCNVector3(0, visibleHeight / 2, width / 2 - thickness / 2)
        
        // Unsichtbare Wände
        let leftInvisibleWall = createInvisibleWall(width: thickness, height: invisibleHeight, length: width)
        leftInvisibleWall.position = SCNVector3(-width / 2 + thickness / 2, visibleHeight + invisibleHeight / 2, 0)
        
        let rightInvisibleWall = createInvisibleWall(width: thickness, height: invisibleHeight, length: width)
        rightInvisibleWall.position = SCNVector3(width / 2 - thickness / 2, visibleHeight + invisibleHeight / 2, 0)
        
        let frontInvisibleWall = createInvisibleWall(width: width, height: invisibleHeight, length: thickness)
        frontInvisibleWall.position = SCNVector3(0, visibleHeight + invisibleHeight / 2, -width / 2 + thickness / 2)
        
        let backInvisibleWall = createInvisibleWall(width: width, height: invisibleHeight, length: thickness)
        backInvisibleWall.position = SCNVector3(0, visibleHeight + invisibleHeight / 2, width / 2 - thickness / 2)
        
        // Äußere Wände
        let leftOuterWall = createVisibleWall(width: thickness, height: outerHeight, length: width)
        leftOuterWall.position = SCNVector3(-width / 2 - thickness / 2, outerHeight / 2, 0)
        
        let rightOuterWall = createVisibleWall(width: thickness, height: outerHeight, length: width)
        rightOuterWall.position = SCNVector3(width / 2 + thickness / 2, outerHeight / 2, 0)
        
        let backOuterWall = createVisibleWall(width: width + (thickness * 2), height: outerHeight, length: thickness)
        backOuterWall.position = SCNVector3(0, outerHeight / 2, width / 2 + thickness / 2)
        
        // Zweite Reihe äußerer Wände
        let leftOuterWall2 = createVisibleWall(width: thickness, height: outerHeight2, length: width + (thickness * 2))
        leftOuterWall2.position = SCNVector3(-width / 2 - thickness * 1.5, outerHeight / 2, thickness)
        
        let rightOuterWall2 = createVisibleWall(width: thickness, height: outerHeight2, length: width + (thickness * 2))
        rightOuterWall2.position = SCNVector3(width / 2 + thickness * 1.5, outerHeight / 2, thickness)
        
        let backOuterWall2 = createVisibleWall(width: width + (thickness * 4), height: outerHeight2, length: thickness)
        backOuterWall2.position = SCNVector3(0, outerHeight / 2, width / 2 + thickness * 1.5)
        
        // Würfelablage
        let wuerfelAblageUnterteil = createVisibleWall(width: width + (thickness * 4), height: outerHeight2, length: frontThickness)
        wuerfelAblageUnterteil.position = SCNVector3(0, visibleHeight / 2.7, -width / 2 - thickness * 4)
        
        let upLeft = createVisibleWall(width: 1.1, height: 0.3, length: frontThickness)
        upLeft.position = SCNVector3(x: -4.85, y: 1.35, z: -5.8)
        
        let upRight = createVisibleWall(width: 1.1, height: 0.3, length: frontThickness)
        upRight.position = SCNVector3(x: 4.85, y: 1.35, z: -5.8)
        
        let upBack = createVisibleWall(width: 10, height: 0.3, length: 0.2)
        upBack.position = SCNVector3(x: 0, y: 1.35, z: -5.1)
        
        let upFront = createVisibleWall(width: 10, height: 0.3, length: 0.2)
        upFront.position = SCNVector3(x: 0, y: 1.35, z: -6.5)
        
        let upMiddle = createVisibleWall(width: 0.3, height: 0.3, length: frontThickness)
        upMiddle.position = SCNVector3(x: 0.05, y: 1.35, z: -5.8)
        
        let upMiddleLeft1 = createVisibleWall(width: 0.3, height: 0.3, length: frontThickness)
        upMiddleLeft1.position = SCNVector3(x: -1.45, y: 1.35, z: -5.8)
        
        let upMiddleLeft2 = createVisibleWall(width: 0.3, height: 0.3, length: frontThickness)
        upMiddleLeft2.position = SCNVector3(x: -2.95, y: 1.35, z: -5.8)
        
        let upMiddleRight1 = createVisibleWall(width: 0.3, height: 0.3, length: frontThickness)
        upMiddleRight1.position = SCNVector3(x: 1.55, y: 1.35, z: -5.8)
        
        let upMiddleRight2 = createVisibleWall(width: 0.3, height: 0.3, length: frontThickness)
        upMiddleRight2.position = SCNVector3(x: 3.05, y: 1.35, z: -5.8)
        
        // Behälterknoten
        let containerNode = SCNNode()
        containerNode.addChildNode(bottomNode)
        containerNode.addChildNode(leftVisibleWall)
        containerNode.addChildNode(rightVisibleWall)
        containerNode.addChildNode(frontVisibleWall)
        containerNode.addChildNode(backVisibleWall)
        containerNode.addChildNode(leftInvisibleWall)
        containerNode.addChildNode(rightInvisibleWall)
        containerNode.addChildNode(frontInvisibleWall)
        containerNode.addChildNode(backInvisibleWall)
        containerNode.addChildNode(leftOuterWall)
        containerNode.addChildNode(rightOuterWall)
        containerNode.addChildNode(backOuterWall)
        containerNode.addChildNode(leftOuterWall2)
        containerNode.addChildNode(rightOuterWall2)
        containerNode.addChildNode(backOuterWall2)
        containerNode.addChildNode(wuerfelAblageUnterteil)
        containerNode.addChildNode(upLeft)
        containerNode.addChildNode(upBack)
        containerNode.addChildNode(upFront)
        containerNode.addChildNode(upRight)
        containerNode.addChildNode(upMiddle)
        containerNode.addChildNode(upMiddleLeft1)
        containerNode.addChildNode(upMiddleLeft2)
        containerNode.addChildNode(upMiddleRight1)
        containerNode.addChildNode(upMiddleRight2)
        
        return containerNode
    }
    
    func rollDiceFinally() {
        resetDicePositionsAfterThrow()
        tapped = false
        if (selectedDiceNodes.count == 6) {
            print("6 Dice selected")
            selectedDiceNodes.removeAll()
            selectedDiceNodesArray.removeAll()
            takenDiceNodes.removeAll()
        }
        restorePhysicsBodies()
        
        var count = 1
        diceNodes.forEach({ diceNode in
            if !selectedDiceNodes.contains(diceNode) {
                diceNode.physicsBody?.clearAllForces()
                switch count {
                case 1: diceNode.position = dice1IntitalPosition
                case 2: diceNode.position = dice2IntitalPosition
                case 3: diceNode.position = dice3IntitalPosition
                case 4: diceNode.position = dice4IntitalPosition
                case 5: diceNode.position = dice5IntitalPosition
                case 6: diceNode.position = dice6IntitalPosition
                default: return
                }
                
                let randomX = isLocalGame ? localGame.diceRotations[count - 1].x : game.diceRotations[count - 1].x
                let randomY = isLocalGame ? localGame.diceRotations[count - 1].y : game.diceRotations[count - 1].y
                let randomZ = isLocalGame ? localGame.diceRotations[count - 1].z : game.diceRotations[count - 1].z
                
                let torque = SCNVector4(x: randomX, y: randomY, z: randomZ, w: 1.0)
                diceNode.physicsBody?.applyTorque(torque, asImpulse: true)
                diceNode.physicsBody?.applyForce(SCNVector3(x: 0, y: -10, z: 0), asImpulse: true)
                count += 1
            }
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            self.arrangeDiceAfterThrow()
            self.tapped = true
            self.checkDiceValues()
            self.checkDiceValuesAfterThrow()
            if (!self.isThrownDiceValid && self.isLocalGame) {
                print("zero")
                self.zero()
            } else if (!self.isThrownDiceValid && !self.isLocalGame && self.game.players[self.game.currentPlayerIndex].username == self.username) {
                print("zero")
                self.zero()
            }
            
            if !self.isLocalGame && self.username == self.game.players[self.game.currentPlayerIndex].username {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.syncDice()
                }
            }
        }
    }
    
    func restorePhysicsBodies() {
        for diceNode in diceNodes {
            if !selectedDiceNodes.contains(diceNode) {
                if diceNode.physicsBody?.type == .static {
                    diceNode.physicsBody?.type = .dynamic
                }
                if diceNode.physicsBody == nil {
                    let dice = diceNode.geometry as! SCNBox
                    let shape = SCNPhysicsShape(geometry: dice, options: nil)
                    diceNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
                    diceNode.physicsBody?.mass = 1.0
                    diceNode.physicsBody?.restitution = 0.5
                    diceNode.physicsBody?.friction = 0.5
                    diceNode.physicsBody?.categoryBitMask = 0b0001
                    diceNode.physicsBody?.contactTestBitMask = 0b0010
                    diceNode.physicsBody?.collisionBitMask = 0b1111
                }
            }
        }
    }
    
    func arrangeSelectedDice() {
        let startPosition = SCNVector3(x: -3.7, y: 1.8, z: -5.8)
        let spacing = 1.5
        
        var index = 0
        for diceNode in selectedDiceNodesArray {
            let newPosition = SCNVector3(x: startPosition.x + Float(index) * Float(spacing), y: startPosition.y, z: startPosition.z)
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 1.0
            
            // Bewege den Würfel zur neuen Position
            diceNode.position = newPosition
            
            // Setze die Geschwindigkeit und Drehgeschwindigkeit auf Null
            diceNode.physicsBody?.velocity = SCNVector3Zero
            diceNode.physicsBody?.angularVelocity = SCNVector4Zero
            
            // Ändere den Typ des Physikkörpers zu statisch
            diceNode.physicsBody?.type = .static
            
            SCNTransaction.commit()
            index += 1
        }
    }
    
    func arrangeDice() {
        let startPosition = SCNVector3(x: -3.7, y: 0.5, z: 0)
        let spacing = 1.5
        
        var index = 0
        print("DiceNodes: \(diceNodes.count)")
        for diceNode in diceNodes {
            let newPosition = SCNVector3(x: startPosition.x + Float(index) * Float(spacing) , y: startPosition.y, z: startPosition.z)
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 1.0
            
            // Bewege den Würfel zur neuen Position
            diceNode.position = newPosition
            
            // Setze die Geschwindigkeit und Drehgeschwindigkeit auf Null
            diceNode.physicsBody?.velocity = SCNVector3Zero
            diceNode.physicsBody?.angularVelocity = SCNVector4Zero
            
            // Ändere den Typ des Physikkörpers zu statisch
            diceNode.physicsBody?.type = .static
            
            SCNTransaction.commit()
            index += 1
        }
    }
    
    func arrangeDiceAfterThrow() {
        let startPosition = SCNVector3(x: -3.7, y: 2.5, z: 0)
        let spacing = 1.5
        
        var index = 0
        for diceNode in diceNodes {
            if !takenDiceNodes.contains(diceNode) {
                let newPosition = SCNVector3(x: startPosition.x + Float(index) * Float(spacing) , y: startPosition.y, z: startPosition.z)
                
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 1.0
                
                // Bewege den Würfel zur neuen Position
                diceNode.position = newPosition
                
                // Richte den Würfel gerade aus
                alignDice(diceNode)
                
                // Setze die Geschwindigkeit und Drehgeschwindigkeit auf Null
                diceNode.physicsBody?.velocity = SCNVector3Zero
                diceNode.physicsBody?.angularVelocity = SCNVector4Zero
                
                // Ändere den Typ des Physikkörpers zu statisch
                diceNode.physicsBody?.type = .static
                
                SCNTransaction.commit()
                
                // Speichere nur die neue Position
                dicePositionsAfterThrow[diceNode] = newPosition
                
                index += 1
            }
        }
    }
    
    
    func alignDice(_ diceNode: SCNNode) {
        let currentRotation = diceNode.eulerAngles
        print("Current Euler Angles: \(diceNode.eulerAngles)")
        // Bestimme die aktuelle obere Seite des Würfels
        let diceTransform = diceNode.presentation.worldTransform
        
        // Extrahieren der Rotationskomponente aus der Transformationsmatrix
        let rotationMatrix = SCNMatrix4(
            m11: diceTransform.m11, m12: diceTransform.m12, m13: diceTransform.m13, m14: 0,
            m21: diceTransform.m21, m22: diceTransform.m22, m23: diceTransform.m23, m24: 0,
            m31: diceTransform.m31, m32: diceTransform.m32, m33: diceTransform.m33, m34: 0,
            m41: 0, m42: 0, m43: 0, m44: 1
        )
        
        // Berechnen Sie die Richtungsvektoren für alle sechs Seiten des Würfels
        let upVector = SCNVector3(0, 1, 0).applying(rotationMatrix).normalized()
        let downVector = SCNVector3(0, -1, 0).applying(rotationMatrix).normalized()
        let rightVector = SCNVector3(1, 0, 0).applying(rotationMatrix).normalized()
        let leftVector = SCNVector3(-1, 0, 0).applying(rotationMatrix).normalized()
        let frontVector = SCNVector3(0, 0, 1).applying(rotationMatrix).normalized()
        let backVector = SCNVector3(0, 0, -1).applying(rotationMatrix).normalized()
        
        let topFace = determineTopFace([upVector, downVector, rightVector, leftVector, frontVector, backVector])
        
        print("Current top face: \(topFace)")
        
        // Wende die Rotation an
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0
        if (topFace == 1) {
            if diceNode.eulerAngles.x != -1.5707963 {
                diceNode.eulerAngles = SCNVector3(x: -1.5707963, y: 0.0, z: 0.0)
            } else {
                diceNode.eulerAngles = SCNVector3(x: 4.712389, y: 0.0, z: 0.0)
            }
        } else if topFace == 2 {
            if diceNode.eulerAngles.z != 1.5707963 {
                diceNode.eulerAngles = SCNVector3(x: 1.5707963, y: 0.0, z: 1.5707963)
            } else {
                diceNode.eulerAngles = SCNVector3(x: 1.5707963, y: 0.0, z: -4.712389)
            }
        } else if topFace == 3 {
            if diceNode.eulerAngles.x != 1.5707963 {
                diceNode.eulerAngles = SCNVector3(x: 1.5707963, y: 0.0, z: 0.0)
            } else {
                diceNode.eulerAngles = SCNVector3(x: -4.712389, y: 0.0, z: 0.0)
            }
        } else if topFace == 4 {
            if diceNode.eulerAngles.z != -1.5707963 {
                diceNode.eulerAngles = SCNVector3(x: 0.0, y: 0.0, z: -1.5707963)
            } else {
                diceNode.eulerAngles = SCNVector3(x: 0.0, y: 0.0, z: 4.712389)
            }
        } else if (topFace == 5) {
            if diceNode.eulerAngles.x != 6.283185 {
                diceNode.eulerAngles = SCNVector3(x: 6.283185, y: 0.0, z: 0.0)
            } else {
                diceNode.eulerAngles = SCNVector3(x: 0, y: 0.0, z: 0.0)
            }
        } else if topFace == 6 {
            if diceNode.eulerAngles.x != 3.1415925 {
                diceNode.eulerAngles = SCNVector3(x: 3.1415925, y: 0.0, z: 0.0)
            } else {
                diceNode.eulerAngles = SCNVector3(x: -3.1415925, y: 0.0, z: 0.0)
            }
        }
        
        SCNTransaction.commit()
        
        print("Aligned dice. Final rotation: \(diceNode.eulerAngles)")
    }
    
    func alignFalseDice(diceName: String, to: Int) {
        
        diceNodes.forEach({diceNode in
            if diceNode.name == diceName {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0
                if (to == 1) {
                    if diceNode.eulerAngles.x != -1.5707963 {
                        diceNode.eulerAngles = SCNVector3(x: -1.5707963, y: 0.0, z: 0.0)
                    } else {
                        diceNode.eulerAngles = SCNVector3(x: 4.712389, y: 0.0, z: 0.0)
                    }
                } else if to == 2 {
                    if diceNode.eulerAngles.z != 1.5707963 {
                        diceNode.eulerAngles = SCNVector3(x: 1.5707963, y: 0.0, z: 1.5707963)
                    } else {
                        diceNode.eulerAngles = SCNVector3(x: 1.5707963, y: 0.0, z: -4.712389)
                    }
                } else if to == 3 {
                    if diceNode.eulerAngles.x != 1.5707963 {
                        diceNode.eulerAngles = SCNVector3(x: 1.5707963, y: 0.0, z: 0.0)
                    } else {
                        diceNode.eulerAngles = SCNVector3(x: -4.712389, y: 0.0, z: 0.0)
                    }
                } else if to == 4 {
                    if diceNode.eulerAngles.z != -1.5707963 {
                        diceNode.eulerAngles = SCNVector3(x: 0.0, y: 0.0, z: -1.5707963)
                    } else {
                        diceNode.eulerAngles = SCNVector3(x: 0.0, y: 0.0, z: 4.712389)
                    }
                } else if (to == 5) {
                    if diceNode.eulerAngles.x != 6.283185 {
                        diceNode.eulerAngles = SCNVector3(x: 6.283185, y: 0.0, z: 0.0)
                    } else {
                        diceNode.eulerAngles = SCNVector3(x: 0, y: 0.0, z: 0.0)
                    }
                } else if to == 6 {
                    if diceNode.eulerAngles.x != 3.1415925 {
                        diceNode.eulerAngles = SCNVector3(x: 3.1415925, y: 0.0, z: 0.0)
                    } else {
                        diceNode.eulerAngles = SCNVector3(x: -3.1415925, y: 0.0, z: 0.0)
                    }
                }
                
                SCNTransaction.commit()
            }
        })
    }
    
    func rotationForTopFace(_ face: Int) -> SCNVector3 {
        switch face {
        case 1: return SCNVector3(-Float.pi / 2, 0, 0)
        case 2: return SCNVector3(0, 0, Float.pi / 2)
        case 3: return SCNVector3(Float.pi / 2, 0, 0)
        case 4: return SCNVector3(0, 0, -Float.pi / 2)
        case 5: return SCNVector3(0, 0, 0)
        case 6: return SCNVector3(Float.pi, 0, 0)
        default: return SCNVector3(0, 0, 0)
        }
    }
    
    func checkDiceValues() {
        let diceNodes = rootNode.childNodes.filter({ $0.geometry is SCNBox && $0.name != "floor"})
        diceValues.removeAll()
        
        diceNodes.forEach { diceNode in
            let diceTransform = diceNode.presentation.worldTransform
            
            // Extrahieren der Rotationskomponente aus der Transformationsmatrix
            let rotationMatrix = SCNMatrix4(
                m11: diceTransform.m11, m12: diceTransform.m12, m13: diceTransform.m13, m14: 0,
                m21: diceTransform.m21, m22: diceTransform.m22, m23: diceTransform.m23, m24: 0,
                m31: diceTransform.m31, m32: diceTransform.m32, m33: diceTransform.m33, m34: 0,
                m41: 0, m42: 0, m43: 0, m44: 1
            )
            
            // Berechnen Sie die Richtungsvektoren für alle sechs Seiten des Würfels
            let upVector = SCNVector3(0, 1, 0).applying(rotationMatrix).normalized()
            let downVector = SCNVector3(0, -1, 0).applying(rotationMatrix).normalized()
            let rightVector = SCNVector3(1, 0, 0).applying(rotationMatrix).normalized()
            let leftVector = SCNVector3(-1, 0, 0).applying(rotationMatrix).normalized()
            let frontVector = SCNVector3(0, 0, 1).applying(rotationMatrix).normalized()
            let backVector = SCNVector3(0, 0, -1).applying(rotationMatrix).normalized()
            
            print("Dice position: \(diceNode.presentation.position)")
            print("Up vector: \(upVector)")
            print("Down vector: \(downVector)")
            print("Right vector: \(rightVector)")
            print("Left vector: \(leftVector)")
            print("Front vector: \(frontVector)")
            print("Back vector: \(backVector)")
            
            let topFace = determineTopFace([upVector, downVector, rightVector, leftVector, frontVector, backVector])
            let diceValue = DiceValue(value: topFace, diceName: diceNode.name!)
            diceValues.append(diceValue)
        }
    }
    
    func checkDiceValuesAfterThrow() {
        print("checkDiceValuesAfterThrow")
        let diceNodes = rootNode.childNodes.filter({ $0.geometry is SCNBox && $0.name != "floor"})
        isLocalGame ? localGame.thrownDiceValues.removeAll() : game.thrownDiceValues.removeAll()
        
        diceNodes.forEach { diceNode in
            if !selectedDiceNodes.contains(diceNode) {
                let diceTransform = diceNode.presentation.worldTransform
                
                // Extrahieren der Rotationskomponente aus der Transformationsmatrix
                let rotationMatrix = SCNMatrix4(
                    m11: diceTransform.m11, m12: diceTransform.m12, m13: diceTransform.m13, m14: 0,
                    m21: diceTransform.m21, m22: diceTransform.m22, m23: diceTransform.m23, m24: 0,
                    m31: diceTransform.m31, m32: diceTransform.m32, m33: diceTransform.m33, m34: 0,
                    m41: 0, m42: 0, m43: 0, m44: 1
                )
                
                // Berechnen Sie die Richtungsvektoren für alle sechs Seiten des Würfels
                let upVector = SCNVector3(0, 1, 0).applying(rotationMatrix).normalized()
                let downVector = SCNVector3(0, -1, 0).applying(rotationMatrix).normalized()
                let rightVector = SCNVector3(1, 0, 0).applying(rotationMatrix).normalized()
                let leftVector = SCNVector3(-1, 0, 0).applying(rotationMatrix).normalized()
                let frontVector = SCNVector3(0, 0, 1).applying(rotationMatrix).normalized()
                let backVector = SCNVector3(0, 0, -1).applying(rotationMatrix).normalized()
                
                let topFace = determineTopFace([upVector, downVector, rightVector, leftVector, frontVector, backVector])
                let diceValue = topFace
                
                isLocalGame ? localGame.thrownDiceValues.append(DiceValue(value: diceValue, diceName: "")) : game.thrownDiceValues.append(DiceValue(value: diceValue, diceName: diceNode.name!))
                print("Added DiceNode to thrownDiceValues")
            }
        }
        isThrownDiceValid = checkThrownDice()
        print("isThrownDiceValid: \(isThrownDiceValid)")
    }
    
    func checkThrownDice() -> Bool {
        
        if isLocalGame ? localGame.thrownDiceValues.contains(where: { $0.value == 1 || $0.value == 5 }) : game.thrownDiceValues.contains(where: { $0.value == 1 || $0.value == 5 }) {
            print("1 or 5")
            return true
        }
        
        if localGameController.isStreet(isLocalGame ? localGame.thrownDiceValues : game.thrownDiceValues) || localGameController.isThreePairs(isLocalGame ? localGame.thrownDiceValues : game.thrownDiceValues) {
            return true
        }
        
        let counts = [2, 3, 4, 6]
        var atLeastOneTriple = false
        
        for count in counts {
            if isLocalGame ? localGame.thrownDiceValues.filter({ $0.value == count }).count >= 3 : game.thrownDiceValues.filter({ $0.value == count }).count >= 3 {
                atLeastOneTriple = true
            }
        }
        
        if !atLeastOneTriple {
            return false
        }
        
        return true
    }
    
    private func determineTopFace(_ vectors: [SCNVector3]) -> Int {
        let upVector = SCNVector3(0, 1, 0)
        var maxDot: Float = -1
        var topFaceIndex = 0
        
        for (index, vector) in vectors.enumerated() {
            let dot = SCNVector3.dot(vector, upVector)
            if dot > maxDot {
                maxDot = dot
                topFaceIndex = index
            }
        }
        
        // Korrigierte Zuordnung der Augenzahlen
        let faceValueMap = [0: 5, 1: 6, 2: 2, 3: 4, 4: 1, 5: 3]
        let topFace = faceValueMap[topFaceIndex] ?? 1
        
        return topFace
    }
    
    func toggleRoundEnded() {
        print("toggleRoundEnded")
        selectedDiceNodes.removeAll()
        selectedDiceNodesArray.removeAll()
        takenDiceNodes.removeAll()
        // Zurücksetzen der Würfel auf ihre Anfangspositionen und -rotationen
        for (index, diceNode) in diceNodes.enumerated() {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // Setze die Position zurück
            switch index {
            case 0: diceNode.position = dice1IntitalPosition
            case 1: diceNode.position = dice2IntitalPosition
            case 2: diceNode.position = dice3IntitalPosition
            case 3: diceNode.position = dice4IntitalPosition
            case 4: diceNode.position = dice5IntitalPosition
            case 5: diceNode.position = dice6IntitalPosition
            default: break
            }
            
            SCNTransaction.commit()
        }
        arrangeDice()
    }
    
    func connect() {
        print("connect")
        gameClient.connect()
    }
    
    func createGame() {
        if isLocalGame {
            createLocalGame()
        } else {
            game.gameId = generateGameId()
            gameClient.createGame(gameId: game.gameId, username: username)
        }
    }
    
    func startGame() {
        gameClient.startGame(gameId: game.gameId)
    }
    
    func checkIfGameExists(gameId: String) {
        gameClient.checkIfGameExists(gameId: gameId)
    }
    
    func joinGame(gameId: String) {
        gameClient.joinGame(gameId: gameId, username: username)
        game.gameId = gameId
        self.gameId = gameId
        if game.disconnectedPlayers.first(where: {$0.username == username}) != nil {
            currentView = .main
        } else {
            currentView = .lobby
        }
    }
    
    func rollDice() {
        if isLocalGame {
            let diceRotations = localGameController.createRandomDiceRotations()
            localGame.diceRotations = diceRotations
            localGame.thrown = true
            rollDiceFinally()
        } else {
            gameClient.rollDice(gameId: game.gameId)
        }
    }
    
    func deductPointsFromPlayer(selectedPlayer: Player) {
        if isLocalGame {
            for index in localGame.players.indices {
                if localGame.players[index].username == selectedPlayer.username {
                    localGame.players[index].score -= 500
                }
            }
        } else {
            gameClient.deductPointsFromPlayer(gameId: game.gameId, selectedPlayer: selectedPlayer)
        }
    }
    
    func calculateRoundScore() {
        gameClient.calculateRoundScore(gameId: game.gameId)
    }
    
    func zero() {
        if isLocalGame {
            localGame = localGameController.zero(game: localGame)
            toggleRoundEnded()
            takenDiceNodes.removeAll()
        } else {
            gameClient.zero(gameId: game.gameId)
        }
    }
    
    func endRound() {
        gameClient.endRound(gameId: game.gameId)
    }
    
    func syncDice() {
        gameClient.syncDice(gameId: game.gameId, diceValues: diceValues)
    }
    
    func leaveGame() {
        gameClient.leaveGame(gameId: game.gameId, username: username)
    }
    
    func disconnect() {
        gameClient.disconnect()
    }
    
    func verifyAndCorrectDiceValues(_ serverValues: [DiceValue]) {
        
        serverValues.forEach { (serverValue: DiceValue) in
            if let localValue = diceValues.filter({ $0.diceName == serverValue.diceName }).first {
                if localValue.value != serverValue.value {
                    print("Correcting dice \(serverValue.diceName) from \(localValue.value) to \(serverValue.value)")
                    alignFalseDice(diceName: localValue.diceName, to: serverValue.value)
                    diceValues = diceValues.map { (diceValue: DiceValue) -> DiceValue in
                        if diceValue.diceName == serverValue.diceName {
                            var updatedDiceValue = diceValue
                            updatedDiceValue.value = serverValue.value
                            return updatedDiceValue
                        } else {
                            return diceValue
                        }
                    }
                }
            }
        }
    }
    
    func localDiceSelected(index: Int, value: Int) {
        if let diceIndex = localGame.selectedDice.firstIndex(where: { $0.index == index }) {
            // Wenn der Würfel bereits ausgewählt ist, entfernen wir ihn
            localGame.selectedDice.remove(at: diceIndex)
        } else {
            // Wenn der Würfel noch nicht ausgewählt ist, fügen wir ihn hinzu
            localGame.selectedDice.append(Dice(index: index, value: value))
        }
        
        isValidSelection = localCheckSelectedDice()
        
        toggleDiceSelected(index: index)
        
        localGameController.calculateThrowScore(game: &localGame)
    }
    
    func localCheckSelectedDice() -> Bool {
        if diceValues.isEmpty {
            return false
        }
        
        if localGameController.isStreet(diceValues) || localGameController.isThreePairs(diceValues) {
            return true
        }
        
        let counts = [2, 3, 4, 6]
        for count in counts {
            if game.selectedDice.contains(where: { $0.value == count }) {
                if game.selectedDice.filter({ $0.value == count }).count < 3 {
                    return false
                }
            }
        }
        return true
    }
    
    private func generateGameId() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0..<8).map { _ in letters.randomElement()! })
    }
    
    func createLocalGame() {
        print("createLocalGame")
        var player1 = Player()
        player1.username = username
        localGame.players.append(player1)
        print("Players: \(localGame.players)")
    }
    
    func addPlayerToLocalGame(username: String) {
        print("addPlayerToLocalGame")
        var newPlayer = Player()
        newPlayer.username = username
        localGame.players.append(newPlayer)
        print("Players: \(localGame.players)")
    }
    
    func calculateRoundScoreLocal() {
        localGameController.calculateThrowScore(game: &localGame)
        localGame.roundScore += localGame.throwScore;
        localGame.throwScore = 0;
        localGame.selectedDice = []
        selectedDiceNodes.forEach({selectedDiceNode in
            takenDiceNodes.insert(selectedDiceNode)
        })
    }
    
    func endRoundLocal() {
        localGame.takenDice = []
        localGame.selectedDice = []
        localGame.players[localGame.currentPlayerIndex].score += localGame.roundScore + localGame.throwScore
        localGame.players[localGame.currentPlayerIndex].scoreHistory.append(localGame.players[localGame.currentPlayerIndex].score)
        localGame.players[localGame.currentPlayerIndex].zeroCount = 0
        localGame.roundScore = 0
        localGame.throwScore = 0
        localGame.thrown = false
        
        if localGame.players[localGame.currentPlayerIndex].score >= 10000 && localGame.isLastRound == false {
            localGame.isLastRound = true;
            localGame.winnerIndex = localGame.currentPlayerIndex
            localGame.lastRoundCounter += 1
            localGame.currentPlayerIndex = (localGame.currentPlayerIndex + 1) % localGame.players.count;
        } else if localGame.isLastRound && localGame.lastRoundCounter == localGame.players.count - 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                guard let self = self else { return }
                self.localGame.win = true
                localRoundWon()
            }
        } else if localGame.isLastRound {
            localGame.lastRoundCounter += 1
            localGame.currentPlayerIndex = (localGame.currentPlayerIndex + 1) % localGame.players.count;
            if (localGame.players[localGame.currentPlayerIndex].score >= localGame.players[localGame.winnerIndex].score) {
                localGame.winnerIndex = localGame.currentPlayerIndex
            }
        } else {
            localGame.currentPlayerIndex = (localGame.currentPlayerIndex + 1) % localGame.players.count
        }
        
        toggleRoundEnded()
        takenDiceNodes.removeAll()
    }
    
    func localRoundWon() {
        winnerName = localGame.players[localGame.winnerIndex].username
        currentView = .winScreen
        localGame.reset()
    }
    
    func removePlayerFromLocalGame(index: Int) {
        localGame.players.remove(at: index)
    }
    
    func deleteLocalGame() {
        localGame.reset()
    }
    
    func changeUsername(index: Int, newUsername: String) {
        if isLocalGame {
            localGame.players[index].username = newUsername
        } else {
            gameClient.changeUsername(gameId: game.gameId, index: index, newUsername: username)
        }
    }
    
    func removePlayerFromOnlineGame(index: Int) {
        gameClient.removePlayerFromGame(gameId: game.gameId, index: index)
    }
    
    func gotKicked() {
        game.reset()
        currentView = .online
        gameId = ""
        showGotKickedPopUp = true
        print("gotKicked")
    }
}

extension SCNVector3 {
    func normalized() -> SCNVector3 {
        let length = sqrt(x*x + y*y + z*z)
        guard length != 0 else { return self }
        return SCNVector3(x / length, y / length, z / length)
    }
    
    func applying(_ matrix: SCNMatrix4) -> SCNVector3 {
            let x = self.x * matrix.m11 + self.y * matrix.m21 + self.z * matrix.m31 + matrix.m41
            let y = self.x * matrix.m12 + self.y * matrix.m22 + self.z * matrix.m32 + matrix.m42
            let z = self.x * matrix.m13 + self.y * matrix.m23 + self.z * matrix.m33 + matrix.m43
            return SCNVector3(x, y, z)
        }
    
    static func dot(_ v1: SCNVector3, _ v2: SCNVector3) -> Float {
        return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension DiceScene: GameClientDelegate {
    func didWinGame(_ playerId: Int) {
        DispatchQueue.main.async {
            self.winnerName = self.game.players[playerId].username
            self.currentView = .winScreen
        }
    }
        
    func didStartFinalRounds(_ game: GameState) {
        DispatchQueue.main.async {
            self.game = game
            self.showStartedFinalRoundsPopUp = true
        }
    }
    
    func didRemovePlayer(game: GameState, removedUsername: String) {
        DispatchQueue.main.async {
            if removedUsername == self.username {
                print("didRemovePlayer got Kicked")
                self.gotKicked()
            } else {
                self.game = game
            }
        }
    }
    
    func didCheckIfGameExists(_ gameExists: Bool) {
        DispatchQueue.main.async {
            if gameExists {
                self.joinGame(gameId: self.gameId)
            } else {
                self.gameId = ""
            }
        }
    }
    
    func didCalculateRoundScore(_ game: GameState) {
        DispatchQueue.main.async {
            self.game = game
            self.selectedDiceNodes.forEach({selectedDiceNode in
                self.takenDiceNodes.insert(selectedDiceNode)
            })
        }
    }
    
    func didUpdateGame(_ game: GameState) {
        DispatchQueue.main.async {
            self.game = game
        }
    }
    
    func didRollDice(_ game: GameState) {
        DispatchQueue.main.async {
            self.game = game
            self.rollDiceFinally()
        }
    }
    
    func didReceiveValidation(_ isValid: Bool) {
        DispatchQueue.main.async {
            self.isValidSelection = isValid
        }
    }
    
    func didReceiveThrownDiceValidation(_ isValid: Bool) {
        DispatchQueue.main.async {
            self.isThrownDiceValid = isValid
        }
    }
    
    func didCreateGame(_ game: GameState) {
            DispatchQueue.main.async {
                self.game = game
            }
        }
    
    func didSelectDice( index: Int, game: GameState) {
        DispatchQueue.main.async {
            self.game = game
            self.toggleDiceSelected(index: index)
            self.gameClient.calculateThrowScore(gameId: game.gameId)
        }
    }
    
    func didStartGame() {
        DispatchQueue.main.async {
            self.currentView = .main
        }
    }
    
    func didEndRound(_ game: GameState) {
        DispatchQueue.main.async {
            self.game = game
            self.toggleRoundEnded()
            self.takenDiceNodes.removeAll()
        }
    }
    
    func didReceiveFinalDiceValues(_ values: [DiceValue]) {
            DispatchQueue.main.async {
                self.verifyAndCorrectDiceValues(values)
            }
        }
    
    func didLeaveGame(_ username: String) {
        print("didLeaveGame: \(username)")
        DispatchQueue.main.async {
            if (username == self.username) {
                print("remove self")
                self.gameId.removeAll()
                self.game.reset()
            } else {
                print("Remove User \(username)")
                self.game.players.removeAll(where: {$0.username == username})
            }
        }
    }
    
    func didChangeCreator(_ game: GameState) {
        DispatchQueue.main.async {
            self.game = game
        }
    }
}
