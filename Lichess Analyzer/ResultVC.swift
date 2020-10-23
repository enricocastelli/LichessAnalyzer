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

    @IBOutlet weak var winLabel: UILabel!
    @IBOutlet weak var loseLabel: UILabel!
    @IBOutlet weak var drawLabel: UILabel!
    @IBOutlet weak var winPercentageLabel: UILabel!
    @IBOutlet weak var losePercentageLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
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
        sort(.mostPlayed)
        setLabels()
    }

    private func setLabels() {
        titleLabel.text = UserData.shared.name
        subtitleLabel.attributedText = NSMutableAttributedString()
            .normal("Using ")
            .bold(UserData.shared.search.color.rawValue)
            .normal(" in ")
            .bold(UserData.shared.search.gameType.rawValue)
            .normal(" games")
        winLabel.text = games.wins().description
        loseLabel.text = games.lost().description
        drawLabel.text = games.draw().description
        let winPercentage = games.wins().percentage(of: games.count)
        winPercentageLabel.text = winPercentage.description  + "%"
        losePercentageLabel.text = games.lost().percentage(of:games.count).description + "%"
        let _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
            self.progressView.setProgress(Float(winPercentage/100), animated: true)
        }
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
        filterLabel.text = "Most played"
    }

    @IBAction func sortStrongest() {
        hideMenu()
        sort(.strongest)
        tableView.reloadData()
        filterLabel.text = "Strongest"
    }

    @IBAction func sortWeakest() {
        hideMenu()
        sort(.weakest)
        tableView.reloadData()
        filterLabel.text = "Weakest"
    }

    @IBAction func back() {
        navigationController?.popViewController(animated: true)
    }
}
