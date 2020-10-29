//
//  ResultVC.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 21/10/2020.
//

import UIKit

class ResultVC: UIViewController {

    var games: [GameItem] = []
    var source = [KnownOpening: [GameItem]]()
    var sections: [KnownOpening] = []

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var filterLabel: UILabel!

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            setTableView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        filterLabel.text = UserData.shared.preferredSorting.desc()
        setLabels()
        addObserver()
    }

    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateGames), name: .NewGames, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLoad()
    }

    private func setLoad(){
        loadingView.alpha = 0
        if games != UserData.shared.games {
            games = UserData.shared.games
            reloadData()
        }
    }

    func setTableView() {
        let rView = ResultView()
        rView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width/1.5)
        tableView.tableHeaderView = rView
        tableView.register(UINib(nibName: ResultCell.identifier, bundle: nil), forCellReuseIdentifier: ResultCell.identifier)
    }

    func reloadData() {
        Clock.start()
        games = UserData.shared.games
        source = Dictionary(grouping: games, by: { $0.opening })
        sort(UserData.shared.preferredSorting)
        tableView.reloadData()
        (tableView.tableHeaderView as? ResultView)?.update(wins: UserData.shared.games.wins(), loss: UserData.shared.games.lost(), draw: UserData.shared.games.draw())
        setLabels()
        Clock.stop()
    }

    func setLabels() {
        titleLabel.text = UserData.shared.searchName
        subtitleLabel.attributedText = NSMutableAttributedString()
            .normal("using ")
            .normal(" in ")
            .bold(UserData.shared.search.gameType.rawValue)
            .normal(" type games, ")
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

    @objc private func updateGames() {
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

extension ResultVC: UITableViewDataSource, UITableViewDelegate {

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
        let section = sections[indexPath.row]
        guard let games = source[section] else { return }
        let detailItem = DetailItem(opening: section,
                                    win: games.wins(),
                                    loss: games.lost(),
                                    draw: games.draw())
        let source = Dictionary(grouping: games, by: { $0.completeOpening })
        self.navigationController?.pushViewController(DetailVC(source, item: detailItem), animated: true)
    }
}

