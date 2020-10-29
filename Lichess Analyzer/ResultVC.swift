//
//  ResultVC.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 21/10/2020.
//

import UIKit

class ResultVC: UIViewController {

    var games: [GameItem] = []
    var openings: [OpeningGame] {
        return games.mapToOpening()
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var filterLabel: UILabel!

    let dataSource = TableViewDataSource(cellResourceId: ResultCell.identifier)

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            dataSource.tableView = tableView
            dataSource.items = openings
            dataSource.onDidSelectItem = { [weak self] (item) in
                self?.navigationController?.pushViewController(DetailVC(item), animated: true)
            }
            let rView = ResultView()
            rView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width/1.5)
            tableView.tableHeaderView = rView
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        filterLabel.text = UserData.shared.preferredSorting.desc()
        setLabels()
        NotificationCenter.default.addObserver(self, selector: #selector(updateGames), name: .NewGames, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadingView.alpha = 0
        if games != UserData.shared.games {
            games = UserData.shared.games
            reloadData()
        }
    }

    private func reloadData() {
//        sort(UserData.shared.preferredSorting)
        dataSource.items = openings
        tableView.reloadData()
        (tableView.tableHeaderView as? ResultView)?.update(wins: games.wins(), loss: games.lost(), draw: games.draw())
        setLabels()
    }

    private func setLabels() {
        titleLabel.text = UserData.shared.searchName
        subtitleLabel.attributedText = NSMutableAttributedString()
            .normal("using ")
            .normal(" in ")
            .bold(UserData.shared.search.gameType.rawValue)
            .normal(" type games, ")
    }

    func sort(_ sorting: GamesSorting) {
        var sortedOpenings = openings
        switch sorting {
        case .mostPlayed:
            sortedOpenings.sort(by: {$0.results.count > $1.results.count})
        case .strongest:
            sortedOpenings.sort { (g1, g2) -> Bool in
                return g1.points > g2.points
            }
        case .weakest:
            sortedOpenings.sort { (g1, g2) -> Bool in
                return g2.points > g1.points
            }
        }
        dataSource.items = sortedOpenings
    }

    @objc func updateGames() {
        self.games = UserData.shared.games
        showLoading() {
            if self.tableView != nil {
                self.reloadData()
                self.hideLoading()
            }
        }
    }

    func showLoading(_ completion: @escaping() -> ()) {
        UIView.animate(withDuration: 0.3) {
            self.loadingView.alpha = 1
        } completion: { (_) in
            completion()
        }
    }

    func hideLoading() {
        UIView.animate(withDuration: 0.5) {
            self.loadingView.alpha = 0
        }
    }

    func hideMenu() {
        UIView.animate(withDuration: 0.2) {
//            self.filterView.alpha = 0
        }
    }

    func showMenu() {
        UIView.animate(withDuration: 0.3) {
//            self.filterView.alpha = 1
        }
    }

    @IBAction func filterTapped() {
//        filterView.alpha == 0 ? showMenu() : hideMenu()
    }

    @IBAction func sortMostPlayed() {
        hideMenu()
        sort(.mostPlayed)
        tableView.reloadData()
        filterLabel.text = UserData.shared.preferredSorting.desc()
        UserData.shared.preferredSorting = .mostPlayed
    }

    @IBAction func sortStrongest() {
        hideMenu()
        sort(.strongest)
        tableView.reloadData()
        UserData.shared.preferredSorting = .strongest
        filterLabel.text = UserData.shared.preferredSorting.desc()
    }

    @IBAction func sortWeakest() {
        hideMenu()
        sort(.weakest)
        tableView.reloadData()
        UserData.shared.preferredSorting = .weakest
        filterLabel.text = UserData.shared.preferredSorting.desc()
    }

    @IBAction func back() {
        navigationController?.popViewController(animated: true)
    }
}
