//  Created by Umur Gedik on 23.08.2023.

import UIKit

public protocol XUICoordinator: AnyObject {
    var children: [any XUICoordinator] { get set }

    @MainActor
    func start(animated: Bool)
}

public extension XUICoordinator {
    @MainActor
    func removeChild<Coordinator: XUICoordinator>(_ child: Coordinator) {
        children = children.filter { $0 !== child }
    }

    @MainActor
    func makeModalFlow<Output, Flow>(
        modalStyle: UIModalPresentationStyle = .formSheet,
        _ block: (UINavigationController) -> Flow,
        completion: @escaping (Output?) -> Void
    ) -> UIViewController where Flow: XUIUserFlow, Flow.Output == Output {
        let navigationController = UINavigationController()
        let flow = block(navigationController)
        let modalVC = XUIModalViewController(wrapping: navigationController) {
            [weak self, weak flow] in
            guard let self, let flow else { return }
            removeChild(flow)
        }

        flow.completion = {
            [weak self, weak flow, weak modalVC] output in
            modalVC?.dismiss(animated: true)
            guard let self, let flow else { return }
            removeChild(flow)
            completion(output)
        }

        children.append(flow)
        flow.start(animated: false)

        modalVC.modalPresentationStyle = modalStyle
        return modalVC
    }

    @MainActor
    func startFlow<Output, Flow>(
        _ flow: Flow,
        animated: Bool,
        completion: @escaping (Output?) -> Void
    ) where Flow: XUIUserFlow, Flow.Output == Output {
        flow.completion = {
            [weak self, weak flow] output in
            completion(output)
            guard let self, let flow else { return }
            removeChild(flow)
        }

        children.append(flow)
        flow.start(animated: animated)
    }
}
