//
//  TableView.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 21/10/2020.
//

import Foundation
import UIKit

 class TableViewCell<T>: UITableViewCell {
     func configure(_ item: T) {
        selectionStyle = .none
    }
}

class TableViewDataSource<T: Equatable, Cell: TableViewCell<T>>: NSObject, UITableViewDataSource, UITableViewDelegate {

    private let cellResourceResolver: ((T) -> ReuseIdentifier<Cell>)
    private let resourceId: String
    var onDidSelectItem: ((T) -> Void)?
    var onConfigureCell: ((Cell, T) -> Void)?

    weak  var tableView: UITableView? = nil {
        didSet {
            tableView?.dataSource = self
            tableView?.delegate = self
            tableView?.register(UINib(nibName: resourceId, bundle: nil), forCellReuseIdentifier: resourceId)
        }
    }

     var headerView: UIView? {
        get {
            return tableView?.tableHeaderView
        }
        set {
            tableView?.tableHeaderView = newValue
            tableView?.resizeTableHeaderView()
        }
    }

    var items: [T] = []

     var selectedItem: T? {
        guard let selectedIndex = tableView?.indexPathForSelectedRow else { return nil }
        return item(at: selectedIndex)
    }

    init(cellResourceId: ReuseIdentifier<Cell>) {
        self.cellResourceResolver = { _ in cellResourceId }
        self.resourceId = cellResourceId.identifier.description
    }

     func setSelectedItem(_ item: T?, animated: Bool) {
        tableView?.selectRow(at: (item != nil ?  index(of: item!) : nil), animated: animated, scrollPosition: .none)
    }

     func scrollToItem(_ item: T, animated: Bool) {
        guard let index = index(of: item) else { return }
        tableView?.scrollToRow(at: index, at: .middle, animated: animated)
    }

    // MARK: - UITableViewDataSource
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = self.item(at: indexPath) else { return UITableViewCell() }
        let cellResourceId = cellResourceResolver(item)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellResourceId.identifier, for: indexPath) as! Cell
        cell.configure(item)
        onConfigureCell?(cell, item)
        return cell
    }

     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let onDidSelectItem = onDidSelectItem, let item = self.item(at: indexPath) {
            onDidSelectItem(item)
        }
    }

     func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
}

 extension TableViewDataSource {

    func item(at index: IndexPath) -> T? {
        guard index.row < items.count && index.row >= 0 else { return nil }
        return items[index.row]
    }

    func index(of item: T) -> IndexPath? {
        if let row = items.firstIndex(of: item) {
            return IndexPath(row: row, section: 0)
        }
        return nil
    }
}


/// Reuse identifier protocol
 protocol ReuseIdentifierType: IdentifierType {
  /// Type of this reuseable
  associatedtype ReusableType
}

/// Reuse identifier
 struct ReuseIdentifier<Reusable>: ReuseIdentifierType {
  /// Type of this reuseable
   typealias ReusableType = Reusable

  /// String identifier of this reusable
   let identifier: String

  /**
   Create a new ReuseIdentifier based on the string identifier

   - parameter identifier: The string identifier for this reusable

   - returns: A new ReuseIdentifier
  */
   init(identifier: String) {
    self.identifier = identifier
  }
}

/// Base protocol for all identifiers
 protocol IdentifierType: CustomStringConvertible {
  /// Identifier string
  var identifier: String { get }
}

extension IdentifierType {
  /// CustomStringConvertible implementation, returns the identifier
   var description: String {
    return identifier
  }
}

 extension UITableView {

    func resizeTableHeaderView() {
        guard let headerView = self.tableHeaderView else { return }
        var size = headerView.systemLayoutSizeFitting(CGSize(width: self.bounds.width, height: UIView.layoutFittingCompressedSize.height))
        size.width = self.bounds.width
        if headerView.frame.size != size {
            headerView.frame.size = size
            headerView.setNeedsLayout()
            headerView.layoutIfNeeded()
            self.tableHeaderView = nil
            self.tableHeaderView = headerView
            self.layoutIfNeeded()
        }
    }
}
