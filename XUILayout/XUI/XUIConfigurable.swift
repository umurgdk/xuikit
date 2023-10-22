import Foundation

protocol XUIConfigurable { }

extension NSObject: XUIConfigurable { }

extension XUIConfigurable {
    func configure(_ block: (Self) -> Void) -> Self {
        block(self)
        return self
    }
}
