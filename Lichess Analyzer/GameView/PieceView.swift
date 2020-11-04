//
//  PieceView.swift
//  Example
//
//  Created by Steve Barnegren on 26/11/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import SwiftChess

class PieceView: UIView {

    public var piece: Piece {
        didSet {
            update()
        }
    }
    
    public var location: BoardLocation
    
    let imageView = UIImageView()
    
    var selected = false {
        didSet {
            update()
        }
    }
    
    // MARK: - Init
    
    init(piece: Piece, location: BoardLocation) {
        
        // Store properties
        self.piece = piece
        self.location = location
        
        // Super init
        super.init(frame: CGRect.zero)
        
        // Setup image view
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)

        // Update
        update()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not implemented")
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let margin = CGFloat(1)
        imageView.frame = CGRect(x: margin,
                                 y: margin,
                                 width: bounds.size.width - margin*2,
                                 height: bounds.size.height - margin*2)
        
    }
    
    // MARK: - Update
    
    func update() {
        
        let imageName: String!
        
        switch (piece.type, piece.color) {
        case (.rook, .white):
            imageName = "wR"
        case (.knight, .white):
            imageName = "wN"
        case (.bishop, .white):
            imageName = "wB"
        case (.queen, .white):
            imageName = "wQ"
        case (.king, .white):
            imageName = "wK"
        case (.pawn, .white):
            imageName = "wP"
        case (.rook, .black):
            imageName = "bR"
        case (.knight, .black):
            imageName = "bN"
        case (.bishop, .black):
            imageName = "bB"
        case (.queen, .black):
            imageName = "bQ"
        case (.king, .black):
            imageName = "bK"
        case (.pawn, .black):
            imageName = "bP"
        }
        
        let image = UIImage(named: imageName)
        assert(image != nil, "Missing image!")

        imageView.image = image
        
        backgroundColor = UIColor.clear
    }
    
}
