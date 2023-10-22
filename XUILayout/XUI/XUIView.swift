//  Created by Umur Gedik on 23.08.2023.

import UIKit

open class XUIView: UIView {
    public init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public let themeColors = XUITheme.default.native

    open func setupViews() { }
}
