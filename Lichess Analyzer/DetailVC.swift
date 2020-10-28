//
//  DetailVC.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 22/10/2020.
//

import UIKit

class DetailVC: UIViewController {

    let opening: OpeningGame

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterLabel: UILabel!

    let dataSource = TableViewDataSource(cellResourceId: DetailCell.identifier)

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            dataSource.tableView = tableView
            dataSource.items = opening.completeOpenings
            dataSource.onDidSelectItem = { [weak self] item in
                self?.itemSelected(item)
            }
            let rView = ResultView(wins: opening.results.filter({$0 == .win}).count, loss: opening.results.filter({$0 == .lose}).count, draw: opening.results.filter({$0 == .draw}).count)
            rView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width/1.5)
            tableView.tableHeaderView = rView
        }
    }

    init(_ opening: OpeningGame) {
        self.opening = opening
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = opening.opening.name
        sort(UserData.shared.preferredSorting)
        filterLabel.text = UserData.shared.preferredSorting.desc()
    }

    func sort(_ sorting: GamesSorting) {
        var sortedOpenings = opening.completeOpenings
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

    func itemSelected(_ item: CompleteOpeningGame) {
        self.navigationController?.pushViewController(GameVC(item), animated: true)
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
        UserData.shared.preferredSorting = .mostPlayed
        filterLabel.text = UserData.shared.preferredSorting.desc()
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
