//
//  TableView.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 21/10/2020.
//

import Foundation
import UIKit

open class TableViewCell<T>: UITableViewCell {
    open func configure(_ item: T) {
        selectionStyle = .none
    }

}


open class SectionData<T: Equatable>: Equatable {
    public let title: String?
    public let items: [T]

    public init(title: String?, items: [T]) {
        self.title = title
        self.items = items
    }

    public static func == (lhs: SectionData<T>, rhs: SectionData<T>) -> Bool {
        return lhs.title == rhs.title && lhs.items == rhs.items
    }
}

open class TableViewDataSource<T: Equatable, Cell: TableViewCell<T>>: NSObject, UITableViewDataSource, UITableViewDelegate {

    private let cellResourceResolver: ((T) -> ReuseIdentifier<Cell>)
    private let resourceId: String
    open var onDidSelectItem: ((T) -> Void)?
    open var onConfigureCell: ((Cell, T) -> Void)?

    weak open var tableView: UITableView? = nil {
        didSet {
            tableView?.dataSource = self
            tableView?.delegate = self
            tableView?.register(UINib(nibName: resourceId, bundle: nil), forCellReuseIdentifier: resourceId)
        }
    }

    var items: [T] = []

    open var selectedItem: T? {
        guard let selectedIndex = tableView?.indexPathForSelectedRow else { return nil }
        return item(at: selectedIndex)
    }

    public init(cellResourceId: ReuseIdentifier<Cell>) {
        self.cellResourceResolver = { _ in cellResourceId }
        self.resourceId = cellResourceId.identifier.description
    }

    open func setSelectedItem(_ item: T?, animated: Bool) {
        tableView?.selectRow(at: (item != nil ?  index(of: item!) : nil), animated: animated, scrollPosition: .none)
    }

    open func scrollToItem(_ item: T, animated: Bool) {
        guard let index = index(of: item) else { return }
        tableView?.scrollToRow(at: index, at: .middle, animated: animated)
    }

    // MARK: - UITableViewDataSource
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = self.item(at: indexPath) else { return UITableViewCell() }
        let cellResourceId = cellResourceResolver(item)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellResourceId.identifier, for: indexPath) as! Cell
        cell.configure(item)
        onConfigureCell?(cell, item)
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let onDidSelectItem = onDidSelectItem, let item = self.item(at: indexPath) {
            onDidSelectItem(item)
        }
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

public extension TableViewDataSource {

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
public protocol ReuseIdentifierType: IdentifierType {
  /// Type of this reuseable
  associatedtype ReusableType
}

/// Reuse identifier
public struct ReuseIdentifier<Reusable>: ReuseIdentifierType {
  /// Type of this reuseable
  public typealias ReusableType = Reusable

  /// String identifier of this reusable
  public let identifier: String

  /**
   Create a new ReuseIdentifier based on the string identifier

   - parameter identifier: The string identifier for this reusable

   - returns: A new ReuseIdentifier
  */
  public init(identifier: String) {
    self.identifier = identifier
  }
}

/// Base protocol for all identifiers
public protocol IdentifierType: CustomStringConvertible {
  /// Identifier string
  var identifier: String { get }
}

extension IdentifierType {
  /// CustomStringConvertible implementation, returns the identifier
  public var description: String {
    return identifier
  }
}
