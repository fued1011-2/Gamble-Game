# README for *Gamble-Game*

Gamble-Game is an iOS dice game built with SwiftUI and SceneKit. It supports local play on one device as well as online games via a Socket.IO server. The app starts in `GambleGameApp` and immediately loads `RootView`, the central entry point.

---

## Features

- **Multiple views and background music**  
  `RootView` controls navigation between the home screen, menu, lobby, game and winning screens while playing background music.

- **Main game with 3D dice**  
  `MainView` embeds a `SceneKitView`, displays the score and provides actions for rolling dice and ending a round.

- **Game mode selection**  
  In `MenuView` you can choose between local play and online mode. Online mode connects to a Socket.IO server, while local mode creates a new game.

- **Online communication via Socket.IO**  
  `GameClient` connects to `http://localhost:3000` and handles various Socket.IO events to synchronize game state.

- **Local game logic and scoring**  
  `LocalGameController` calculates points based on selected dice combinations and manages round transitions.

- **Background music**  
  `AudioManager` plays music in a loop and can stop it on demand.

---

## Project structure

```
GambleGame/
├── Assets.xcassets    # Images & icons
├── Audio              # AudioManager
├── Controllers        # GameClient, LocalGameController, ...
├── Models             # GameState, Player, ...
├── Scenes             # DiceScene (SceneKit)
├── Views              # SwiftUI views (Menu, Main, Lobby, ...)
└── Properties         # Color and layout constants
```

---

## Requirements

- Xcode 15 or later  
- iOS 17 SDK  
- For online play: running Socket.IO server on `localhost:3000`

---

## Installation & launch

1. Clone the repository and open it in Xcode.  
2. Select a target device (simulator or physical device).  
3. Build & run (`⌘R`).  
4. For online games ensure the Socket.IO server is running on port 3000.

---

## Game rules (short version)

- Roll up to six dice.  
- Combine dice to score points. Single ones and fives are worth points; higher values come from triples, quadruples, etc.  
- You must score at least 350 points in a round to end it and bank the points.  
- The game ends when a player reaches 10 000 points and final rounds are completed.

---

Have fun playing!

