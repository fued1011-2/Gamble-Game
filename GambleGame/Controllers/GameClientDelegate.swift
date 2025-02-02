protocol GameClientDelegate: AnyObject {
    func didUpdateGame(_ game: GameState)
    func didCalculateRoundScore(_ game: GameState)
    func didRollDice(_ game: GameState)
    func didReceiveValidation(_ isValid: Bool)
    func didCreateGame(_ game: GameState)
    func didStartGame()
    func didSelectDice(index: Int, game: GameState)
    func didEndRound(_ game: GameState)
    func didReceiveFinalDiceValues(_ values: [DiceValue])
    func didLeaveGame(_ username: String)
    func didCheckIfGameExists(_ gameExists: Bool)
    func didChangeCreator(_ game: GameState)
    func didRemovePlayer(game: GameState, removedUsername: String)
    func didStartFinalRounds(_ game: GameState)
    func didWinGame(_ playerId: Int)
}
