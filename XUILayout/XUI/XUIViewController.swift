//  Created by Umur Gedik on 23.08.2023.

import UIKit

open class XUIViewController: UIViewController {
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var themeColors = XUITheme.default.native

    lazy var xuiView = XUIView()
    open override func loadView() {
        view = xuiView
        view.backgroundColor = themeColors.background
    }
}
