//  Created by Umur Gedik on 21.10.2023.

import UIKit

public protocol XUITableViewCellBuilder {
    associatedtype Cell: UITableViewCell
    
    static var reuseIdentifier: String { get }
    
    @MainActor
    static func register(in tableView: UITableView)
    
    @MainActor
    func build(tableView: UITableView, indexPath: IndexPath) -> Cell
}

public extension XUITableViewCellBuilder {
    @MainActor
    func dequeueCell(tableView: UITableView, indexPath: IndexPath) -> Cell {
        tableView.dequeueReusableCell(withIdentifier: Self.reuseIdentifier, for: indexPath) as! Cell
    }
    
    @MainActor
    static func register(in tableView: UITableView) {
        tableView.register(Cell.self, forCellReuseIdentifier: reuseIdentifier)
    }
}
