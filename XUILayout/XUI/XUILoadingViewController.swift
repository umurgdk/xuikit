//  Created by Umur Gedik on 28.09.2023.

import UIKit

final class XUILoadingViewController: XUIViewController {
    lazy var indicator = UIProgressView(progressViewStyle: .default)
    override func loadView() {
        super.loadView()
        view.addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}
