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
        self.titleLabel.text = opening.opening.rawValue
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
        let tests = extract()
        var mostSimilarOp = OpeningTest(id: "", name: "", pgn: "")
        var mostSimilarRecord = 99
        for op in tests {
            if op.id == opening.eco.rawValue {
                let similarity = StringSimilarity.levenshtein(aStr: op.name, bStr: item.completeOpening)
                if similarity <= mostSimilarRecord {
                    mostSimilarOp = op
                    mostSimilarRecord = similarity
                }
            }
        }
        print(mostSimilarOp)
    }

    func extract() -> [OpeningTest] {
        if let path = Bundle.main.path(forResource: "Openings", ofType: "json")
        {
            if let jsonData = NSData(contentsOfFile: path) {
                do {
                    return try JSONDecoder().decode([OpeningTest].self, from: Data(jsonData))
                } catch(let error) {
                    print(error, "nope")
                }
            }
        }
        return []
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
