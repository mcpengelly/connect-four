//
//  ConnectBoardView.swift
//  connect4-swiftui
//
//  Created by Matt Pengelly on 2022-09-26.
//

import SwiftUI


//challenges:
//wiring up data model to UI controls
//win state checking (optimized based on the last checker played to save scanning entire grid after every turn)
//
//TODO:
//do not hardcode player turn order
//do not hardcode input selection
//do not hardcode grid boundary checks
//player nicknames
//fix warning in image below
//better UI pieces
//
//Stretch:
//arbitrary grid size
//arbitrary player count
//
//Not sure if:
//board should be passed around so much in data model

struct ConnectBoardView: View {
    @State var board = Board()
    @State var gameState = GameStates.Inactive
    @State var playerTurn: Int?
    @State var winnerId: Int?
    
    let game = Game()
    let player1 = Player()
    let player2 = Player()
    
//        init() {
//            print("testing horizontal win")
//            game.test_HorizontalWin()
//            print("testing vertical win")
//            game.test_VerticalWin()
//            print("testing diagonal win")
//            game.test_DiagonalWin()
//        }
    
    var body: some View {
        let gridVisual = VStack {
            ForEach(board.grid, id: \.self) { row in
                HStack {
                    ForEach(row, id: \.self) { column in
                        Text("[\(column)]")
                    }
                }
            }
        }
        
        let inputSelection = HStack {
            ForEach(0...5, id: \.self) { index in
                Button("[\(index)]") {
                    print("pressed: \(index)")
                    print("inputting checker now..")
                   
                    // refactor to remove hardcode
                    if playerTurn == 1 {
                        player1.placeChecker(board: &board, column: index)
                        let isGameOver = game.checkGameOverOptimized(board: &board)
                        if isGameOver {
                            gameState = .GameOver
                        }
                        playerTurn = 2
                        winnerId = 1
                    } else if playerTurn == 2 {
                        player2.placeChecker(board: &board, column: index)
                        let isGameOver = game.checkGameOverOptimized(board: &board)
                        if isGameOver {
                            gameState = .GameOver
                        }
                        winnerId = 2
                        playerTurn = 1
                    } else {
                        print("no idea whos turn it is")
                    }
                }
            }
        }
        
        let StartGameButton = Button("Start game") {
            gameState = .Active
            playerTurn = 1
        }
        
        let ResetGameButton = Button("Reset Game") {
            board.resetBoard()
            gameState = .Inactive
            playerTurn = 1
            winnerId = nil
        }
        
        switch gameState {
            case .Inactive:
                StartGameButton
                Text("Game waiting to start")
            case .Active:
                Text("Game is Playing!")
                Text("Player\(playerTurn ?? 99) choose a column to put a checker!")
                inputSelection
                gridVisual
                ResetGameButton
                Button("Quit Game") {
                    gameState = GameStates.Inactive
                    playerTurn = nil
                    winnerId = nil
                }
            case .GameOver:
                gridVisual
                Text("Game Over! Winner is: Player\(winnerId ?? 99)")
                ResetGameButton
        }
    }
}



struct ConnectBoardView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectBoardView()
    }
}
