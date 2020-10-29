//
//  DetailVC.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 22/10/2020.
//

import UIKit

struct DetailItem {

    let opening: KnownOpening
    let win: Int
    let loss: Int
    let draw: Int
}

class DetailVC: UIViewController {

    var source = [CompleteOpening: [GameItem]]()
    var sections: [CompleteOpening] = []
    let item: DetailItem


    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterLabel: UILabel!

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            let rView = ResultView()
            rView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width/1.5)
            tableView.tableHeaderView = rView
            rView.update(wins: item.win, loss: item.loss, draw: item.draw)
            tableView.register(UINib(nibName: ResultCell.identifier, bundle: nil), forCellReuseIdentifier: ResultCell.identifier)
        }
    }

    init(_ opening: [CompleteOpening: [GameItem]], item: DetailItem) {
        self.source = opening
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = item.opening.name
        subtitleLabel.text = (item.win + item.loss + item.draw).description + " Games"
        sort(UserData.shared.preferredSorting)
        filterLabel.text = UserData.shared.preferredSorting.desc()
        sort(UserData.shared.preferredSorting)
        tableView.reloadData()
    }

    func sort(_ sorting: GamesSorting) {
        switch sorting {
        case .mostPlayed:
            sections = source.sortedKeysByValue { $0.count > $1.count }
        case .strongest:
            sections = source.sortedKeysByValue { $0.points > $1.points }
        case .weakest:
            sections = source.sortedKeysByValue { $0.points < $1.points }
        }
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

extension DetailVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ResultCell.identifier, for: indexPath) as! ResultCell
        let section = sections[indexPath.row]
        let games = source[sections[indexPath.row]]
        cell.configure((section, games))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationController?.pushViewController(GameVC(sections[indexPath.row]), animated: true)
    }
}
