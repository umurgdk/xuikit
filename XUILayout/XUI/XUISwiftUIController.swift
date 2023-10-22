//  Created by Umur Gedik on 3.10.2023.

import SwiftUI

open class XUISwiftUIController<Content: View>: XUIViewController {
    public let content: Content
    public init(content: Content) {
        self.content = content
        super.init()
    }

    var theme: XUITheme = .default
    private lazy var hostingController = UIHostingController(
        rootView: XUIWrapperView(
            content: content,
            theme: theme,
            dismissAction: XUIDismissAction { @MainActor [weak self] animated, completion in
                self?.dismiss(animated: animated, completion: completion)
            }
        )
    )

    public lazy var backgroundColor: UIColor = theme.native.background {
        didSet {
            if isViewLoaded {
                hostingController.view.backgroundColor = backgroundColor
            }
        }
    }

    open override func loadView() {
        super.loadView()

        view.backgroundColor = .clear

        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = backgroundColor
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        hostingController.didMove(toParent: self)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
    }
}

public struct XUIDismissAction {
    let onDismiss: (Bool, (() -> Void)?) -> Void

    @MainActor
    func perform(animated: Bool, completion: (() -> Void)? = nil) {
        onDismiss(animated, completion)
    }
}

private struct XUIWrapperView<Content: View>: View {
    let content: Content
    let theme: XUITheme
    let dismissAction: XUIDismissAction
    var body: some View {
        content
            .environment(\.xuiTheme, theme)
            .environment(\.xuiDismiss, dismissAction)

    }
}

private struct XUIDismissKey: EnvironmentKey {
    static let defaultValue = XUIDismissAction(onDismiss: { _, comp in comp?() })
}

public extension EnvironmentValues {
    var xuiDismiss: XUIDismissAction {
        get { self[XUIDismissKey.self] }
        set { self[XUIDismissKey.self] = newValue }
    }
}

