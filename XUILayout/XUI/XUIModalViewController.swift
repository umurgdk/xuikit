//  Created by Umur Gedik on 6.10.2023.

import UIKit

open class XUIModalViewController: XUIViewController {
    public let wrapped: UIViewController
    public var onDismiss: () -> Void
    public init(wrapping wrapped: UIViewController, onDismiss: @escaping () -> Void) {
        self.wrapped = wrapped
        self.onDismiss = onDismiss
        super.init()
    }

    open override func loadView() {
        super.loadView()

        addChild(wrapped)
        view.addSubview(wrapped.view)
        wrapped.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            wrapped.view.topAnchor.constraint(equalTo: view.topAnchor),
            wrapped.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            wrapped.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            wrapped.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        wrapped.didMove(toParent: self)
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onDismiss()
    }
}
