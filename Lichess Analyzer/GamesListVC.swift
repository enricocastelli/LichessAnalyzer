//
//  GamesListVC.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 20/11/2020.
//

import UIKit

class GamesListVC: UIViewController {

    let games: [GameItem]

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            setTableView()
        }
    }

    init(games: [GameItem]) {
        self.games = games.sorted(by: { (g1, g2) -> Bool in
            return g1.validDate > g2.validDate
        })
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = games.first?.completeOpening.name
        subtitleLabel.text = "You played this variant \(games.count) times.\n\(games.wins()) wins, \(games.lost()) losses, \(games.draw()) draws."
    }

    private func setTableView() {
        tableView.register(UINib(nibName: GameCell.identifier, bundle: nil), forCellReuseIdentifier: GameCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }

    @IBAction func close() {
        self.dismiss(animated: true, completion: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension GamesListVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GameCell.identifier, for: indexPath) as! GameCell
        cell.configure(games[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let game = games[indexPath.row]
        let isBlack = game.black == U.shared.account?.username
        let urlString = game.site + (isBlack ? "/black#0" : "#0")
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
