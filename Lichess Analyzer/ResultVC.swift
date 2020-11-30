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
    @IBOutlet weak var timingButton: FilterButton!
    @IBOutlet var filterStacks: [FilterStackView]!
    @IBOutlet var colorStack: FilterStackView!
    @IBOutlet var sortingStack: FilterStackView!
    @IBOutlet var otherStack: FilterStackView!
    @IBOutlet weak var timingLabel: UILabel!
    @IBOutlet var timingSlider: TimeSlider!
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
        setSlider()
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
        showLoadingAnimation()
        games = UserData.shared.games
        source = Dictionary(grouping: games, by: { $0.opening })
        filteredSource = source
        sortAndFilter {
            Clock.stop()
            self.reloadTableView()
            self.hideLoadingAnimation()
        }
        setFilters()
    }

    private func setSlider() {
        timingSlider.setThumbImage(UIImage(named: "sliderThumb"), for: .normal)
        timingSlider.setThumbImage(UIImage(named: "sliderThumb"), for: .selected)
        timingSlider.setThumbImage(UIImage(named: "sliderThumb"), for: .highlighted)
        switch U.shared.filters.timing {
        case .accountCreation: timingSlider.setValue(0, animated: false)
        case .lastYear: timingSlider.setValue(0.15, animated: false)
        case .last6Months: timingSlider.setValue(0.3, animated: false)
        case .lastMonth: timingSlider.setValue(0.45, animated: false)
        case ._15Days: timingSlider.setValue(0.7, animated: false)
        case ._7Days: timingSlider.setValue(0.85, animated: false)
        case .today: timingSlider.setValue(1, animated: false)
        }
        timingLabel.text = U.shared.filters.timing.desc()
        U.shared.filters.timing == .accountCreation ? timingButton.unselected() : timingButton.selected()
        timingSlider.onTouchEnded = sliderStopped
    }

    // reload UI, typically after sorting/filter
    func reloadTableView() {
        DispatchQueue.main.async {
            self.updateLabels()
            (self.tableView.tableHeaderView as? ResultView)?.update(wins: self.filteredGames.wins(), loss: self.filteredGames.lost(), draw: self.filteredGames.draw())
            self.tableView.reloadData()
        }
    }

    func updateLabels() {
        titleLabel.text = UserData.shared.searchName
        subtitleLabel.attributedText = NSMutableAttributedString()
            .bold(filteredGames.count.description, true)
            .normal(" ", true)
            .bold(U.shared.search.gameType.rawValue, true)
            .normal(" games", true)
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

    func sortAndFilter(_ shouldReload: Bool = true, completion: @escaping() -> ()) {
        let sorting = U.shared.filters.sorting
        Clock.start("Filter")
        let sortGroup = DispatchGroup()
        sortGroup.enter()
        let dispatchQueue = DispatchQueue(label: "Sort", qos: .default)
        dispatchQueue.async(group: sortGroup, qos: .default, flags: []) {
            self.filter()
        }
        sortGroup.leave()
        sortGroup.notify(queue: .global(qos: .default)) {
            Clock.stop()
            Clock.start("Sorting")
            switch sorting {
            case .mostPlayed:
                self.sections = self.filteredSource.sortedKeysByValue { $0.count > $1.count }
            case .strongest:
                self.sections = self.filteredSource.sortedKeysByValue { $0.points > $1.points }
            case .weakest:
                self.sections = self.filteredSource.sortedKeysByValue { $0.points < $1.points }
            }
            completion()
            Clock.stop()
        }
    }

    func filter() {
        let filterDate = U.shared.filters.timing.date() ?? Date()
        let color = U.shared.filters.color
        let termination = U.shared.filters.termination
        let terminationString: String = {
            guard termination != .allTermination else { return "m" }
            return termination == .time ? "time" : "normal"
        }()
        switch color {
        case .white:
            self.filteredGames = self.games.filter({
                $0.white.lowercased() == UserData.shared.searchName.lowercased() &&
                    $0.termination.lowercased().contains(terminationString) &&
                    $0.validDate > filterDate
            })
            self.filteredSource = Dictionary(grouping: self.filteredGames, by: { $0.opening })
        case .black:
            self.filteredGames = self.games.filter({
                $0.black.lowercased() == UserData.shared.searchName.lowercased() &&
                    $0.termination.lowercased().contains(terminationString) &&
                    $0.validDate > filterDate
            })
            self.filteredSource = Dictionary(grouping: self.filteredGames, by: { $0.opening })
        case .blackAndWhite:
            self.filteredGames = self.games.filter({
                $0.termination.lowercased().contains(terminationString) &&
                    $0.validDate > filterDate
            })
            self.filteredSource = Dictionary(grouping: self.filteredGames, by: { $0.opening })
        }
    }

    @objc private func updateGames() {
        if self.tableView != nil {
            setLoad()
        }
    }

    var filterOpened = false

    func hideMenu() {
        filterView.transform = CGAffineTransform(translationX: 0, y: -2)
        UIView.animate(withDuration: 0.1) {
            self.filterView.transform = CGAffineTransform.identity
        }
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
        filterView.transform = CGAffineTransform(translationX: 0, y: -2)
        filterViewHeight.priority = .low
        filterViewHeight.constant = 40
        UIView.animate(withDuration: 0.1) {
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

    @IBAction func sortTapped(sender: FilterButton) {
        guard !sender.isCurrent && sender.sorting != "timing" else {
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
        sortAndFilter {
            self.reloadTableView()
            self.hideLoadingAnimation()
        }
        sender.didSelect()
    }

    var sliderValue: Timing = U.shared.filters.timing

    @IBAction func sliderChanged(_ sender: Any) {
        switch timingSlider.value {
        case let x where x == 0: U.shared.filters.timing = .accountCreation
        case let x where x < 0.15: U.shared.filters.timing = .lastYear
        case let x where x < 0.3: U.shared.filters.timing = .last6Months
        case let x where x < 0.45: U.shared.filters.timing = .lastMonth
        case let x where x < 0.7: U.shared.filters.timing = ._15Days
        case let x where x < 0.85: U.shared.filters.timing = ._7Days
        default: U.shared.filters.timing = .today
        }
        timingLabel.text = U.shared.filters.timing.desc()
        U.shared.filters.timing == .accountCreation ? timingButton.unselected() : timingButton.selected()
    }

    func sliderStopped() {
        guard sliderValue != U.shared.filters.timing else { return }
        sliderValue = U.shared.filters.timing
        showLoadingAnimation()
        sortAndFilter {
            self.reloadTableView()
            self.hideLoadingAnimation()
        }
    }

    @IBAction func back() {
        guard let homeVC = navigationController?.viewControllers[1] as? HomeVC else { return }
        if homeVC.callInProgress {
            if self.isKind(of: DetailVC.self) {
                (self.navigationController as? Navigation)?.pop()
            }
        } else {
            (self.navigationController as? Navigation)?.pop()
        }
    }

    @IBAction func deleteAll() {
        let alert = UIAlertController(title: "🤓",
                                      message: "Are you sure you want to delete all \(U.shared.search.gameType) games?", preferredStyle: .alert)
        let firstAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            self.deleteGames(gameType: U.shared.search.gameType) {
                UserData.shared.games = []
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
        (self.navigationController as? Navigation)?.push(DetailVC(source, item: detailItem))
    }
}

