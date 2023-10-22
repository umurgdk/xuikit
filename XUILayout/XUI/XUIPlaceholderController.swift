//  Created by Umur Gedik on 2.10.2023.

import UIKit

open class XUIPlaceholderController: XUIViewController {
    public init(title: String) {
        super.init()
        label.text = title
    }

    private let label = UILabel().configure {
        $0.font = .preferredFont(forTextStyle: .title3)
    }

    open override func loadView() {
        super.loadView()
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: -32)
        ])
    }
}
