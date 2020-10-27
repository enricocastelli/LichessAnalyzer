//
//  ResultVC.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 21/10/2020.
//

import UIKit

class ResultVC: UIViewController {

    let games: [GameItem]
    let openings: [OpeningGame]

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterLabel: UILabel!


    let dataSource = TableViewDataSource(cellResourceId: ResultCell.identifier)

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            dataSource.tableView = tableView
            dataSource.items = openings
            dataSource.onDidSelectItem = { [weak self] (item) in
                self?.navigationController?.pushViewController(DetailVC(item), animated: true)
            }
            let rView = ResultView(wins: games.wins(), loss: games.lost(), draw: games.draw())
            rView.frame = CGRect(x: 0, y: 0, width: 200, height: 300)
            tableView.tableHeaderView = rView
        }
    }

    init(_ games: [GameItem]) {
        self.games = games
        self.openings = games.mapToOpening()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        sort(UserData.shared.preferredSorting)
        filterLabel.text = UserData.shared.preferredSorting.desc()
        setLabels()
        let most = games.mostCommonOpenings()
        for (k,v) in (Array(most).sorted {$0.1 > $1.1}) {
            print("\(k):\(v)")
        }
    }

    private func setLabels() {
        titleLabel.text = UserData.shared.searchName
        subtitleLabel.attributedText = UserData.shared.search.attrString
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

    func hideMenu() {
        UIView.animate(withDuration: 0.2) {
            self.filterView.alpha = 0
        }
    }

    func showMenu() {
        UIView.animate(withDuration: 0.3) {
            self.filterView.alpha = 1
        }
    }

    @IBAction func filterTapped() {
        filterView.alpha == 0 ? showMenu() : hideMenu()
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
