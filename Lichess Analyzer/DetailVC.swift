//
//  DetailVC.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 22/10/2020.
//

import UIKit

struct DetailItem {

    let opening: KnownOpening
    let filteredGames: [GameItem]
}

class DetailVC: ResultVC {

    let item: DetailItem
    let opening: [CompleteOpening: [GameItem]]

    init(_ opening: [CompleteOpening: [GameItem]], item: DetailItem) {
        self.item = item
        self.opening = opening
        super.init(nibName: "ResultVC", bundle: nil)
        self.games = item.filteredGames
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        colorStack.isHidden = !hasBWColor()
        otherStack.isHidden = true
        trashButton.isHidden = true
    }

    override func addObserver() {}

    private func hasBWColor() -> Bool {
        if U.shared.filters.color == .blackAndWhite { return true }
        var BW = (false, false)
        for game in item.filteredGames {
            if game.white == U.shared.searchName {
                BW.0 = true
            } else if game.black == U.shared.searchName {
                BW.1 = true
            }
        }
        return BW == (true, true)
    }

    override func updateLabels() {
        titleLabel.text = item.opening.name
        subtitleLabel.attributedText = NSMutableAttributedString()
            .bold(filteredGames.count.description)
            .normal(" ")
            .bold(U.shared.search.gameType.rawValue)
            .normal(" games")
    }

    override func reloadData() {
        Clock.start()
        source = opening
        filteredSource = opening
        filter(U.shared.filters.color, U.shared.filters.termination, false)
        sort(U.shared.filters.sorting, false)
        reloadTableView()
        updateLabels()
        setFilters()
        Clock.stop()
    }

    override func filter(_ color: Color, _ termination: Termination, _ shouldReload: Bool = true) {
        switch color {
        case .white:
            filteredGames = item.filteredGames.filter({$0.white == UserData.shared.searchName })
        case .black:
            filteredGames = item.filteredGames.filter({$0.black == UserData.shared.searchName })
        case .blackAndWhite:
            filteredGames = item.filteredGames
        }
        filteredSource = Dictionary(grouping: filteredGames, by: { $0.completeOpening })
        if shouldReload {
            reloadTableView()
        }
    }

    override func setTableView() {
        let rView = ResultView()
        rView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width/1.5)
        tableView.tableHeaderView = rView
        rView.update(wins: filteredGames.wins(),
                     loss: filteredGames.lost(),
                     draw: filteredGames.draw())
        tableView.register(UINib(nibName: ResultCell.identifier, bundle: nil), forCellReuseIdentifier: ResultCell.identifier)
    }

    override func setFilters() {
        super.setFilters()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sections[indexPath.row]
        let games = filteredSource[section] ?? []
        self.navigationController?.pushViewController(GameVC((section, games)), animated: true)
    }
}
