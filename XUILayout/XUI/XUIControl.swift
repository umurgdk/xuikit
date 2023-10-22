//  Created by Umur Gedik on 6.10.2023.

import UIKit

open class XUIControl: UIControl {
    public init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public let themeColors: XUITheme.NativeColors = XUITheme.default.native

    open func setupViews() { }
}
