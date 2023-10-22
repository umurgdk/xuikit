//  Created by Umur Gedik on 3.10.2023.

import UIKit

public protocol XUIUserFlow: XUICoordinator {
    associatedtype Output

    var completion: @MainActor (Output?) -> Void { get set }

    @MainActor
    func runAsync() async -> Output?
}

public extension XUIUserFlow {
    @MainActor
    func runAsync() async -> Output? {
        await withCheckedContinuation { cont in
            completion = { output in
                cont.resume(returning: output)
            }
        }
    }
}
