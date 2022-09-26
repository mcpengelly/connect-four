//
//  connect4-model.swift
//  connect4-swiftui
//
//  Created by Matt Pengelly on 2022-09-26.
//

import Foundation
import UIKit

class Player {
    static var playerCount: Int = 0
    var playerId: Int
    
    init(){
        Player.playerCount += 1
        self.playerId = Player.playerCount
    }
    
    deinit {
        Player.playerCount -= 1
    }
    
    func placeChecker(board: inout Board, column: Int) {
        do {
            try board.placeChecker(column: column, playerId: playerId)
        } catch {
            print("player could not place checker")
        }
    }
}

enum GameStates {
    case Active, GameOver, Inactive
}


struct Game {
    var gameState: GameStates
    
    init(){
        self.gameState = GameStates.Inactive
    }
    
    func test_HorizontalWin() {
        let game = Game()
        let player1 = Player()
        var board = Board()
        board.resetBoard()
        
        player1.placeChecker(board: &board, column: 0)
        player1.placeChecker(board: &board, column: 2)
        player1.placeChecker(board: &board, column: 3)
        print("========== next board state testHorizontalWin ============")
        board.displayBoard()
        
        print("is game over?", game.checkGameOverOptimized(board: &board))
        assert(game.checkGameOverOptimized(board: &board) == false)
        player1.placeChecker(board: &board, column: 1)
    
        print("========== next board state testHorizontalWin ============")
        board.displayBoard()
        print("is game over?", game.checkGameOverOptimized(board: &board))
        assert(game.checkGameOverOptimized(board: &board) == true)
    }
    
    func test_VerticalWin() {
            let player1 = Player()
            let game = Game()
            var board = Board()
            board.resetBoard()
        
            player1.placeChecker(board: &board, column: 0)
            player1.placeChecker(board: &board, column: 0)
            player1.placeChecker(board: &board, column: 0)
            print("========== next board state testVerticalWin ============")
            board.displayBoard()
            print("is game over?", game.checkGameOverOptimized(board: &board))
            assert(game.checkGameOverOptimized(board: &board) == false)
            player1.placeChecker(board: &board, column: 0)
        
            print("========== next board state testVerticalWin ============")
            board.displayBoard()
            print("is game over?", game.checkGameOverOptimized(board: &board))
            assert(game.checkGameOverOptimized(board: &board) == true)
    }
    
    func test_DiagonalWin(){
        let player1 = Player()
        let player2 = Player()
        let game = Game()
        var board = Board()
        board.resetBoard()
        
        player1.placeChecker(board: &board, column: 0)
        player1.placeChecker(board: &board, column: 0)
        player1.placeChecker(board: &board, column: 0)
        player1.placeChecker(board: &board, column: 0)
        player1.placeChecker(board: &board, column: 2)
        player1.placeChecker(board: &board, column: 3)
        player1.placeChecker(board: &board, column: 3)
        player2.placeChecker(board: &board, column: 3)
        player2.placeChecker(board: &board, column: 3)
        player1.placeChecker(board: &board, column: 4)
        player1.placeChecker(board: &board, column: 1)
        player1.placeChecker(board: &board, column: 4)
        player1.placeChecker(board: &board, column: 4)
        player1.placeChecker(board: &board, column: 4)
        print("========== next board state ============")
        board.displayBoard()
        player1.placeChecker(board: &board, column: 4)
        player1.placeChecker(board: &board, column: 4)
        player2.placeChecker(board: &board, column: 5)
        player2.placeChecker(board: &board, column: 5)
        player2.placeChecker(board: &board, column: 5)
        print("========== next board state ============")
        board.displayBoard()
        assert(game.checkGameOverOptimized(board: &board) == false)
        print("is game over?", game.checkGameOverOptimized(board: &board))
        player1.placeChecker(board: &board, column: 5)
        print("========== next board state ============")
        board.displayBoard()
        assert(game.checkGameOverOptimized(board: &board) == true)
        print("is game over?", game.checkGameOverOptimized(board: &board))
    }
    
    // relies on the last played checker to reduce search space
    func checkGameOverOptimized(board: inout Board) -> Bool {
        let lastPlayed = board.lastPlayedCheckerIndices
        let lastPlayer = board.lastPlayerId
        
        if let lastPlayerId = lastPlayer {
            return (
                checkHorizontal(board: &board, row: lastPlayed.row, column: lastPlayed.column, lastPlayerId: lastPlayerId) ||
                checkVertical(board: board, row: lastPlayed.row, column: lastPlayed.column, lastPlayerId: lastPlayerId) ||
                checkDiagonal(board: board, row: lastPlayed.row, column: lastPlayed.column, lastPlayerId: lastPlayerId)
            )
        } else {
            return false
        }
    }
    
    // start from the current board place
    // check 2 spaces to the right and the left
    // if contains the same playerId, check its right again, if its not continuous just break out
    private func checkHorizontal(board: inout Board, row: Int, column: Int, lastPlayerId: Int) -> Bool {
        // check right
        var successiveCheckers = 1
        for index in 1..<4 {
            let right = column + index
            
            if right > 5 {
                break
            }
            
            if board.grid[row][right] == lastPlayerId {
                print("found match at row \(row), column \(right)")
                successiveCheckers += 1
            } else {
                // if none found then consider this non-continuous and breakout
                break
            }
        }
        
        // check left
        for index in 1..<4 {
            // TODO: make variable to row start index
            let left = column - index
            
            if left < 0 {
                break
            }
            if board.grid[row][left] == lastPlayerId {
                print("found match at row \(row), column \(left)")
                successiveCheckers += 1
            } else {
                // if none found then consider this non-continuous and breakout
                break
            }
        }
        if(successiveCheckers >= 4){
            return true
        } else {
            return false
        }
    }
    
    // start from the current board place
    // if contains the same playerId, check its right again. do this for 4 cells, if its not continuous just break out
    private func checkVertical(board: Board, row: Int, column: Int, lastPlayerId: Int) -> Bool {
        // check right
        var successiveCheckers = 1
        for index in 1..<4 {
            let down = row + index
            
            if down > 5 {
                break
            }
            
            if board.grid[down][column] == lastPlayerId {
                print("found match at row \(down), column \(column)")
                successiveCheckers += 1
            } else {
                // if none found then consider this non-continuous and breakout
                break
            }
        }
        
        // check left
        for index in 1..<4 {
            // TODO: make variable to row start index
            let up = row - index
            
            if up < 0 {
                break
            }
            if board.grid[up][column] == lastPlayerId {
                print("found match at row \(up), column \(column)")
                successiveCheckers += 1
            } else {
                // if none found then consider this non-continuous and breakout
                break
            }
        }
        //        print(successiveCheckers)
        if(successiveCheckers >= 4){
            return true
        } else {
            return false
        }
    }
    
    // start from the current board place
    // if contains the same playerId, check its right again. do this for 4 cells, if its not continuous just break out
    private func checkDiagonal(board: Board, row: Int, column: Int, lastPlayerId: Int) -> Bool {
        // still missing 2 checks here
        var successiveCheckers = 1
        // check north/west
        for index in 1..<4 {
            // TODO: make variable to column start index
            let north = row - index
            let west = column - index
            if west < 0 || north < 0 {
                break
            }
            let scannedCell = board.grid[north][west]
            if scannedCell == lastPlayerId {
                print("found match at row \(north), column \(west)")
                successiveCheckers += 1
            } else {
                break
            }
        }
        
        // check south/west
        for index in 1..<4 {
            // TODO: make variable to column.length
            // this may not guard properly
            let south = row + index
            let west = column - index
            if south > 5 || west < 0 {
                break
            }
            let scannedCell = board.grid[south][west]
            if scannedCell == lastPlayerId {
                print("found match at row \(south), column \(west)")
                successiveCheckers += 1
            } else {
                break
            }
        }
        if(successiveCheckers >= 4){
            return true
        }
        
        successiveCheckers = 1
        // check north/east
        for index in 1..<4 {
            // TODO: make variable to column start index
            let north = row - index
            let east = column + index
            if north < 0 || east > 5 {
                break
            }
            let scannedCell = board.grid[north][east]
            if scannedCell == lastPlayerId {
                print("found match at row \(north), column \(east)")
                successiveCheckers += 1
            } else {
                break
            }
        }
        
        // check south/east
        for index in 1..<4 {
            // TODO: make variable to column.length
            let south = row + index
            let east = column + index
            if south > 5 || east > 5 {
                break
            }
            let scannedCell = board.grid[south][east]
            if scannedCell == lastPlayerId {
                print("found match at row \(south), column \(east)")
                successiveCheckers += 1
            } else {
                break
            }
        }
        if(successiveCheckers >= 4){
            return true
        }
        return false
    }
}

protocol IBoard {
    var grid: [[Int]] {get set}
    var lastPlayedCheckerIndices: (row: Int, column: Int) {get set} // used to reduce search space, prevents the need to scan the entire board
    mutating func resetBoard()
}

enum InputError: Error {
    case OutOfRange, ColumnAlreadyFull
}

struct Board: IBoard  {
    var grid: [[Int]]
    var lastPlayedCheckerIndices: (row: Int, column: Int)
    var lastPlayerId: Int? = nil
    
    init() {
        self.grid = [[Int]](repeating: [Int](repeating: 0, count: 6), count: 6)
        lastPlayedCheckerIndices = (row: 0, column: 0)
    }
    
    mutating func resetBoard() {
        grid = [[Int]](repeating: [Int](repeating: 0, count: 6), count: 6)
        lastPlayedCheckerIndices = (row: 0, column: 0)
    }
    
    func findLowestOpenCellIndex(column: Int) throws -> Int? {
        // start from top of selected column
        // iterate from 0 to rows.length, check if the value is anything other than 0,
        // if nothing is found, return the highest possible index (representing the lowest row in the grid)
        // update lastPlayedCheckerIndices
        for (index, _) in grid.enumerated() {
            let currentCellValue = grid[index][column]
            
            // if the topmost row is already full
            if index == 0 && currentCellValue != 0 {
                throw InputError.ColumnAlreadyFull
            }
            
            // if not zero assume theres something there already and give back the index above it.
            if currentCellValue != 0 {
                // we are counting up the index, but going from top down on the grid layout.
                return index - 1
            }
        }
        return grid.endIndex - 1 // lowest point in the grid
    }
    
    mutating func placeChecker(column: Int, playerId: Int) throws {
        guard column < 6 else {
            throw InputError.OutOfRange
        }
        do {
            if let firstOpenRowIndex = try findLowestOpenCellIndex(column: column) {
//                print("lowest open row index is: \(firstOpenRowIndex) in chosen column: \(column)")
                grid[firstOpenRowIndex][column] = playerId
                lastPlayedCheckerIndices = (firstOpenRowIndex, column)
                lastPlayerId = playerId
            }
        } catch InputError.ColumnAlreadyFull {
            print("That column is full try again.")
        }
    }
    
    func displayBoard() {
        for row in grid {
            print(row)
        }
    }
    
    // Debug helpers
    func displayCellValue(row: Int, column: Int) {
        print(grid[row][column])
    }
    
    mutating func placeChecker_debug(row: Int, column: Int, checkerValue: Int) throws {
        guard row < 6 && column < 6 else {
            throw InputError.OutOfRange
        }
        grid[row][column] = checkerValue
    }
}

//do {
//    try board.placeChecker_debug(row: 0, column: 0, checkerValue: 1)
//} catch InputError.OutOfRange {
//    print("input error, board was not modified")
//} catch {
//    print("other error")
//}
//print("========== next board state ============")
