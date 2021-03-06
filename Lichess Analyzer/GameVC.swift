//
//  GameVC.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 22/10/2020.
//

import UIKit
import SwiftChess

class GameVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var resetButton: UIButton!

    var boardView: BoardView!

    let opening: CompleteOpeningGame
    var pieceViews = [PieceView]()
    var game: Game!
    var selectedIndex: Int? {
        didSet {
            updatePieceViewSelectedStates()
        }
    }

    var hasMadeInitialAppearance = false

    init(_ opening: CompleteOpeningGame) {
        self.opening = opening
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = opening.completeOpening
        titleLabel.textColor = opening.openingObject == nil ? UIColor.lightGray : .black
        game = Game(firstPlayer: Human(color: .white), secondPlayer: Human(color: .black))
        game.delegate = self
        setupBoard()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        openPGN(true)
    }

    func setupBoard() {
        resetButton.isHidden = true
        boardView = BoardView(frame: containerView.frame)
        containerView.addContentView(boardView)
        boardView.delegate = self
        for location in BoardLocation.all {
            guard let piece = game.board.getPiece(at: location) else {
                continue
            }
            addPieceView(at: location.x, y: location.y, piece: piece)
        }
        viewDidLayoutSubviews()
    }

    private func openPGN(_ delay: Bool) {
        do {
            let moves = try PGN(parse: opening.openingObject?.pgn ?? opening.pgn).moves
            moves.isModernPNG() ? applyMoves(moves, delay) : adapt(moves, delay)
        } catch (let error) {
            print(error)
        }
    }

    private func applyMoves(_ moves: [String], _ delay: Bool) {
        var color = ChessColor.white
        var timelapse = 0.2
        var indexMove = 0
        for move in moves {
            indexMove += 1
            guard indexMove < 8 else { return }
            let correctMove = move.count == 2 ? "P\(move)" : move
            let locMove = String(correctMove.dropFirst())
            guard let grid1 = LocationPos(rawValue: locMove),
                  let loc = grid1.location() else {
                return }
            for piece in game.board.getPieces(color: color) {
                guard piece.type.rawValue == Piece.PieceType.from(correctMove.first!.description).rawValue else { continue }
                let mov = PieceMovement.pieceMovement(for: piece.type)
                if mov.canPieceMove(from: piece.location, to: loc, board: self.game.board) {
                    let playerToMove: Human = color == .white ? game.whitePlayer as! Human : game.blackPlayer as! Human
                    do {
                    try playerToMove.movePiece(from: piece.location, to: loc, delay: timelapse)
                    color = color == .white ? .black : .white
                    timelapse += delay ? 0.4 : 0
                    } catch(let error) {
                        print(error)
                    }
                }
            }
        }
    }

    private func adapt(_ moves: [String], _ delay: Bool) {
        var color = ChessColor.white
        var timelapse = 0.2
        for move in moves {
            guard move.count == 4 else { return }
            let characters = Array(move)
            let from = characters[0].description + characters[1].description
            let to = characters[2].description + characters[3].description
            guard let grid1 = LocationPos(rawValue: from),
                  let loc1 = grid1.location(),
                  let grid2 = LocationPos(rawValue: to),
                  let loc2 = grid2.location()else {
                return }
            let playerToMove: Human = color == .white ? game.whitePlayer as! Human : game.blackPlayer as! Human
            do {
            try playerToMove.movePiece(from: loc1, to: loc2, delay: timelapse)
            color = color == .white ? .black : .white
            timelapse += delay ? 0.4 : 0
            } catch(let error) {
                print(error)
            }
        }
    }


    // MARK: - Manage Piece Views

    func addPieceView(at x: Int, y: Int, piece: Piece) {

        let location = BoardLocation(x: x, y: y)

        let pieceView = PieceView(piece: piece, location: location)
        boardView.addSubview(pieceView)
        pieceViews.append(pieceView)
    }

    func removePieceView(withTag tag: Int) {

        if let pieceView = pieceViewWithTag(tag) {
            removePieceView(pieceView: pieceView)
        }
    }

    func removePieceView(pieceView: PieceView) {

        if let index = pieceViews.firstIndex(of: pieceView) {
            pieceViews.remove(at: index)
        }

        if pieceView.superview != nil {
            pieceView.removeFromSuperview()
        }
    }

    func updatePieceViewSelectedStates() {

        for pieceView in pieceViews {
            pieceView.selected = (pieceView.location.index == selectedIndex)
        }
    }

    func pieceViewWithTag(_ tag: Int) -> PieceView? {
        return pieceViews.first { $0.piece.tag == tag }
    }

    // MARK: - Layout

    override func viewDidLayoutSubviews() {

        // Layout pieces
        for pieceView in pieceViews {

            let gridX = pieceView.location.x
            let gridY = 7 - pieceView.location.y

            let width = boardView.bounds.size.width / 8
            let height = boardView.bounds.size.height / 8

            pieceView.frame = CGRect(x: CGFloat(gridX) * width,
                                     y: CGFloat(gridY) * height,
                                     width: width,
                                     height: height)
        }
    }

    // MARK: - Alerts

    func showAlert(title: String, message: String) {

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(okAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
}


// MARK: - Board view delegate

extension GameVC: BoardViewDelegate {

    func touchedSquareAtIndex(_ boardView: BoardView, index: Int) {
        print(index)
        // Get the player (must be human)
        guard let player = game.currentPlayer as? Human else {
            return
        }

        let location = BoardLocation(index: index)

        // If has tapped the same piece again, deselect it
        if let selectedIndex = selectedIndex {
            if location == BoardLocation(index: selectedIndex) {
                self.selectedIndex = nil
                return
            }
        }

        // Select new piece if possible
        if player.occupiesSquare(at: location) {
            selectedIndex = index
        }

        // If there is a selected piece, see if it can move to the new location
        if let selectedIndex = selectedIndex {

            do {
                try player.movePiece(from: BoardLocation(index: selectedIndex),
                                     to: location)
                resetButton.isHidden = false

            } catch {
            }
        }
    }

}

// MARK: - GameDelegate

extension GameVC: GameDelegate {

    func gameDidChangeCurrentPlayer(game: Game) {}

    func gameWonByPlayer(game: Game, player: Player) { }

    func gameEndedInStaleMate(game: Game) {}

    func gameDidEndUpdates(game: Game) {}


    public func gameWillBeginUpdates(game: Game) {}

    func gameDidAddPiece(game: Game) {}

    func gameDidMovePiece(game: Game, piece: Piece, toLocation: BoardLocation) {

        guard let pieceView = pieceViewWithTag(piece.tag) else {
            return
        }

        pieceView.location = toLocation

        // Animate
        view.setNeedsLayout()

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)

    }

    func gameDidRemovePiece(game: Game, piece: Piece, location: BoardLocation) {

        guard let pieceView = pieceViewWithTag(piece.tag) else {
            return
        }

        // Fade out and remove
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            pieceView.alpha = 0
        }, completion: { (finished: Bool) in
            self.removePieceView(withTag: piece.tag)
        })

    }

    func gameDidTransformPiece(game: Game, piece: Piece, location: BoardLocation) {

        guard let pieceView = pieceViewWithTag(piece.tag) else {
            return
        }

        pieceView.piece = piece
    }


    func promotedTypeForPawn(location: BoardLocation,
                             player: Human,
                             possiblePromotions: [Piece.PieceType],
                             callback: @escaping (Piece.PieceType) -> Void) {

        boardView.isUserInteractionEnabled = false
    }

    @IBAction func back() {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func reset() {
        game = Game(firstPlayer: Human(color: .white), secondPlayer: Human(color: .black))
        game.delegate = self
        boardView.reset()
        pieceViews = [PieceView]()
        setupBoard()
        openPGN(false)
    }


}
