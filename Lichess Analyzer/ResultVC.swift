//
//  ResultVC.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 21/10/2020.
//

import UIKit

class ResultVC: UIViewController, StoreProvider {

    var games: [GameItem]!
    var source = [KnownOpening: [GameItem]]()
    var sections: [KnownOpening] = []

    var filteredGames: [GameItem] = []
    var filteredSource = [KnownOpening: [GameItem]]()

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterViewHeight: NSLayoutConstraint!
    @IBOutlet var filterStacks: [FilterStackView]!
    @IBOutlet var colorStack: FilterStackView!
    @IBOutlet var sortingStack: FilterStackView!
    @IBOutlet var otherStack: FilterStackView!
    @IBOutlet var trashButton: UIButton!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            setTableView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addObserver()
        games = []
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
        //LOADING
        if games != U.shared.games {
            games = U.shared.games
            reloadData()
        }
    }

    func setTableView() {
        let rView = ResultView()
        rView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width/1.5)
        tableView.tableHeaderView = rView
        tableView.register(UINib(nibName: ResultCell.identifier, bundle: nil), forCellReuseIdentifier: ResultCell.identifier)
    }

    // all data is changed needs to reload everything (as view did load)
    func reloadData() {
        Clock.start()
        games = UserData.shared.games
        source = Dictionary(grouping: games, by: { $0.opening })
        filteredSource = source
        filter(UserData.shared.filters.color, UserData.shared.filters.termination, false)
        sort(UserData.shared.filters.sorting, false)
        reloadTableView()
        setFilters()
        Clock.stop()
    }

    // reload UI, typically after sorting/filter
    func reloadTableView() {
        updateLabels()
        (tableView.tableHeaderView as? ResultView)?.update(wins: filteredGames.wins(), loss: filteredGames.lost(), draw: filteredGames.draw())
        tableView.reloadData()
    }

    func updateLabels() {
        titleLabel.text = UserData.shared.searchName
        subtitleLabel.attributedText = NSMutableAttributedString()
            .bold(filteredGames.count.description)
            .normal(" ")
            .bold(U.shared.search.gameType.rawValue)
            .normal(" games")
    }

    func setFilters() {
        let filters = UserData.shared.filters
        colorStack.update(filters.color.rawValue)
        sortingStack.update(filters.sorting.rawValue)
        otherStack.update(filters.termination.rawValue)
        for stack in filterStacks {
            stack.move()
        }
    }

    func sort(_ sorting: GamesSorting, _ shouldReload: Bool = true) {
        Clock.start("Filter")
        switch sorting {
        case .mostPlayed:
            sections = filteredSource.sortedKeysByValue { $0.count > $1.count }
        case .strongest:
            sections = filteredSource.sortedKeysByValue { $0.points > $1.points }
        case .weakest:
            sections = filteredSource.sortedKeysByValue { $0.points < $1.points }
        }
        if shouldReload {
            reloadTableView()
        }
    }

    func filter(_ color: Color, _ termination: Termination, _ shouldReload: Bool = true) {
        let terminationString: String = {
            guard termination != .allTermination else { return "m" }
            return termination == .time ? "time" : "normal"
        }()
        switch color {
        case .white:
            filteredGames = games.filter({$0.white == UserData.shared.searchName && $0.termination.lowercased().contains(terminationString)})
            filteredSource = Dictionary(grouping: filteredGames, by: { $0.opening })
        case .black:
            filteredGames = games.filter({$0.black == UserData.shared.searchName &&
                                            $0.termination.lowercased().contains(terminationString)})
            filteredSource = Dictionary(grouping: filteredGames, by: { $0.opening })
        case .blackAndWhite:
            filteredGames = games.filter({ $0.termination.lowercased().contains(terminationString) })
            filteredSource = Dictionary(grouping: filteredGames, by: { $0.opening })
        }
        if shouldReload {
            reloadTableView()
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
//LOADING
        } completion: { (_) in
            completion()
        }
    }

    func hideLoading() {
        UIView.animate(withDuration: 0.5) {
            //LOADING
        }
    }

    var filterOpened = false

    func hideMenu() {
        filterViewHeight.priority = .high
        filterOpened = false
        for stack in filterStacks {
            stack.move()
        }
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }

    func showMenu() {
        filterView.transform = CGAffineTransform(translationX: 0, y: -4)
        filterViewHeight.priority = .low
        filterViewHeight.constant = 40
        UIView.animate(withDuration: 0.2) {
            self.filterView.transform = CGAffineTransform.identity
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        } completion: { (_) in
            self.filterOpened = true
        }
    }

    @IBAction func filterTapped() {
        filterOpened ? hideMenu() : showMenu()
    }

    @IBAction func sort(sender: FilterButton) {
        guard !sender.isCurrent else {
            filterTapped()
            return }
        showLoadingAnimation()
        if let sorting = GamesSorting(rawValue: sender.sorting) {
            U.shared.filters.sorting = sorting
        } else if let color = Color(rawValue: sender.sorting) {
            U.shared.filters.color = color
        } else if let termination = Termination(rawValue: sender.sorting) {
            U.shared.filters.termination = termination
        }
        filter(U.shared.filters.color, U.shared.filters.termination, false)
        sort(U.shared.filters.sorting)
        sender.didSelect()
        hideLoadingAnimation()
    }

    @IBAction func back() {
        guard let homeVC = navigationController?.viewControllers[1] as? HomeVC else { return }
        if homeVC.callInProgress {
            if self.isKind(of: DetailVC.self) {
                navigationController?.popViewController(animated: true)
            }
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    @IBAction func deleteAll() {
        let alert = UIAlertController(title: "🤓",
                                      message: "Are you sure you want to delete all \(U.shared.search.gameType) games?", preferredStyle: .alert)
        let firstAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            self.deleteGames(gameType: U.shared.search.gameType) {
                self.back()
            } failure: { (error) in }
        }
        alert.addAction(firstAction)
        let secondAction = UIAlertAction(title: "No", style: .default) { (_) in }
        alert.addAction(secondAction)
        self.present(alert, animated: true, completion: nil)
    }
}

extension ResultVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ResultCell.identifier, for: indexPath) as! ResultCell
        let section = sections[indexPath.row]
        let games = filteredSource[sections[indexPath.row]]
        cell.configure((section, games))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        hideMenu()
        let section = sections[indexPath.row]
        guard let games = filteredSource[section] else { return }
        let detailItem = DetailItem(opening: section,
                                    filteredGames: games)
        let source = Dictionary(grouping: games, by: { $0.completeOpening })
        self.navigationController?.pushViewController(DetailVC(source, item: detailItem), animated: true)
    }
}

