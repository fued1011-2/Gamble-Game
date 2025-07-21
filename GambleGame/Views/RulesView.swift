import SwiftUI

struct RulesView: View {
    @ObservedObject var scene: DiceScene
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    // Back Button
                    Button(action: {
                        scene.currentView = .menu
                    }) {
                        Image("back_arrow")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                    }
                    
                    Spacer()
                    
                    Text("Rules")
                        .font(.title)
                        .bold()
                        .padding(.leading, 10)
                    
                    Spacer().frame(width:160)
                }
                .padding(.leading, 20)
                VStack(alignment: .leading, spacing: 16) {
                    
                    Text("🎯 Goal of the Game")
                        .font(.title2.bold())
                    Text("""
To win a game of Gamble you need to have the highest score at the end of the final round. The final round is triggered when a player reaches or surpasses 10,000 points.
""")
                    
                    Text("🎲 How to Play")
                        .font(.title2.bold())
                    Text("""
Players take turns rolling six dice. At the start of your turn, you roll all six dice. You score points by rolling:

• A 1 or 5  
• Three of a kind  
• Three pairs  
• A straight (1–6)

After each roll, you must set aside at least one scoring die. If you can't, it's a Farkle and your round ends with 0 points.

You can then:

• Bank the points (if you have atleast 350 points), or  
• Continue rolling the remaining dice.

⚠️ You can only score with the **newly rolled dice**. Previously scored dice cannot be combined. If you roll and can't score, it's a Farkle and you lose all points for the round.

If you score all six dice, you get to roll all of them again and continue your turn.

If you Farkle three times in a row, you lose 500 points.
""")
                    
                    Divider()
                    
                    Text("📈 Scoring")
                        .font(.title2.bold())
                    
                    Text("• Single Dice:")
                        .font(.headline)
                    VStack(alignment: .leading) {
                        Text("– 1 = 100 points")
                        Text("– 5 = 50 points")
                    }
                    
                    Text("• Three of a Kind:")
                        .font(.headline)
                    VStack(alignment: .leading) {
                        Text("– 1-1-1 = 1,000 points")
                        Text("– 2-2-2 = 200 points")
                        Text("– 3-3-3 = 300 points")
                        Text("– 4-4-4 = 400 points")
                        Text("– 5-5-5 = 500 points")
                        Text("– 6-6-6 = 600 points")
                    }
                    
                    Text("• Special Combinations:")
                        .font(.headline)
                    VStack(alignment: .leading) {
                        Text("– Three pairs (e.g. 1-1, 3-3, 6-6) = 750 points")
                        Text("– Straight (1–2–3–4–5–6) = 1,500 points")
                    }
                    
                    Text("• Doubling Three-of-a-Kind:")
                        .font(.headline)
                    VStack(alignment: .leading) {
                        Text("– 3 + 3 + 3 = 300 points")
                        Text("– 3 + 3 + 3 + 3 = 300 × 2 = 600 points")
                        Text("– 3 + 3 + 3 + 3 + 3 = 300 × 2 × 2 = 1,200 points")
                        Text("– 3 + 3 + 3 + 3 + 3 + 3 = 300 × 2 × 2 × 2 = 2,400 points")
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle("Game Rules")
    }
}

struct RulesView_Previews: PreviewProvider {
    static var previews: some View {
        RulesView(scene: DiceScene())
    }
}
