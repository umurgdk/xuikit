//  Created by Umur Gedik on 15.09.2023.

import UIKit

open class XUIScrollView: UIScrollView {
    init() {
        super.init(frame: .zero)
        setupViews()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func setupViews() { }
}
