//  Created by Umur Gedik on 22.10.2023.

import UIKit

class ViewController: XUIViewController {
    lazy var layout = XUILayout(
        holder: view,
        placable: XUIVStack(
            children: [
//                XUILabel("Layout Demo")
//                    .padding(.horizontal, 16)
//                    .padding(.vertical, 8)
//                    .background(
//                        XUIBox(color: .secondarySystemBackground, cornerRadius: 16)
//                    )
//                    .padding(.all, 16)
//                    .background(
//                        XUIBox(color: .black, cornerRadius: 32)
//                    ),
                XUIHStack(children: [
                    XUICircle(color: .white).padding(.all, 16).background(XUICircle(color: .systemRed)),
                    XUICircle(color: .white).padding(.all, 16).background(XUICircle(color: .systemGreen)),
                    XUICircle(color: .white).padding(.all, 16).background(XUICircle(color: .systemBlue)),
                ]).padding(.all, 16),
//                XUILabel("with a label"),
//                XUIButton("Switch layout direction") { [weak self] in
//                    guard let view = self?.view else { return }
//                    view.semanticContentAttribute = view.semanticContentAttribute == .forceRightToLeft
//                        ? .unspecified
//                        : .forceRightToLeft
//
//                    UIView.animate(withDuration: 0.35) {
//                        view.layoutIfNeeded()
//                    }
//                },
                XUICircle(color: .systemPurple)
            ]
        )
    )

    override func loadView() {
        super.loadView()
        view.backgroundColor = .secondarySystemBackground
        layout.addSubviews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layout.setFrames(in: view.bounds)
    }
}

struct XUILayout {
    let holder: UIView
    let placable: XUILayoutPlacable

    func addSubviews() {
        placable.addTo(parent: holder)
    }

    func sizeThatFits(proposed: CGSize) -> CGSize {
        let layoutProposal = XUILayoutProposedSize(width: proposed.width, height: proposed.height)
        return placable.sizeThatFits(proposed: layoutProposal, env: makeEnvironment())
    }

    func setFrames(in bounds: CGRect) {
        let env = makeEnvironment()
        let layoutProposal = XUILayoutProposedSize(width: bounds.width, height: bounds.height)
        let size = placable.sizeThatFits(proposed: layoutProposal, env: env)
        var frame = CGRect(origin: .zero, size: size)
        frame.origin.x = (bounds.width - frame.width) / 2
        frame.origin.y = (bounds.height - frame.height) / 2
        placable.placeSubviews(in: frame, proposed: layoutProposal, env: env)
    }

    private func makeEnvironment() -> XUILayoutEnvironment {
        XUILayoutEnvironment(
            layoutDirection: holder.effectiveUserInterfaceLayoutDirection
        )
    }
}

struct XUILayoutEnvironment {
    let layoutDirection: UIUserInterfaceLayoutDirection
}

protocol XUILayoutPlacable {
    var backingView: UIView? { get }
    func sizeThatFits(proposed: XUILayoutProposedSize, env: XUILayoutEnvironment) -> CGSize
    func placeSubviews(in bounds: CGRect, proposed: XUILayoutProposedSize, env: XUILayoutEnvironment)
    func addTo(parent: UIView)
}

extension XUILayoutPlacable {
    var backingView: UIView? { nil }
    func addTo(parent: UIView) {
        if let backingView {
            parent.addSubview(backingView)
        }
    }
}

extension XUILayoutPlacable {
    func frame(width: CGFloat, height: CGFloat, alignment: XUIAlignment = .center) -> XUIFixedFrame<Self> {
        XUIFixedFrame(width: width, height: height, alignment: alignment, child: self)
    }

    func padding(_ edges: XUIEdges, _ amount: CGFloat) -> XUIPadding<Self> {
        XUIPadding(inset: XUIEdgeInset(edges: edges, amount: amount), child: self)
    }

    func background<Background: XUILayoutPlacable>(_ child: Background) -> XUIBackground<Background, Self> {
        XUIBackground(child: child, content: self)
    }
}

struct XUIEdges: OptionSet {
    let rawValue: Int

    static let leading = XUIEdges(rawValue: 1 << 0)
    static let trailing = XUIEdges(rawValue: 1 << 1)
    static let top = XUIEdges(rawValue: 1 << 2)
    static let bottom = XUIEdges(rawValue: 1 << 3)

    static let horizontal: XUIEdges = [.leading, .trailing]
    static let vertical: XUIEdges = [.top, .bottom]
    static let all: XUIEdges = [.leading, .trailing, .top, .bottom]
}

struct XUIEdgeInset: Equatable {
    var top: CGFloat
    var leading: CGFloat
    var bottom: CGFloat
    var trailing: CGFloat

    static let zero = XUIEdgeInset()

    var horizontal: CGFloat {
        leading + trailing
    }

    var vertical: CGFloat {
        top + bottom
    }

    var extent: XUIEdgeInset {
        XUIEdgeInset(
            top: -top,
            leading: -leading,
            bottom: -bottom,
            trailing: -trailing
        )
    }

    init(top: CGFloat = 0, leading: CGFloat = 0, bottom: CGFloat = 0, trailing: CGFloat = 0) {
        self.top = top
        self.leading = leading
        self.bottom = bottom
        self.trailing = trailing
    }

    init(edges: XUIEdges, amount: CGFloat) {
        if edges.contains(.top) {
            top = amount
        } else {
            top = 0
        }

        if edges.contains(.leading) {
            leading = amount
        } else {
            leading = 0
        }

        if edges.contains(.bottom) {
            bottom = amount
        } else {
            bottom = 0
        }

        if edges.contains(.trailing) {
            trailing = amount
        } else {
            trailing = 0
        }
    }
}

extension CGSize {
    func inset(by inset: XUIEdgeInset) -> CGSize {
        CGSize(
            width: max(0, width - inset.horizontal),
            height: max(0, height - inset.vertical)
        )
    }
}

extension CGRect {
    func inset(by inset: XUIEdgeInset, layoutDirection: UIUserInterfaceLayoutDirection) -> CGRect {
        var newRect = self
        let isRTL = layoutDirection == .rightToLeft

        newRect.size = newRect.size.inset(by: inset)

        newRect.origin.x += (isRTL ? 0 : inset.leading)
        newRect.origin.x += (isRTL ? inset.trailing : 0)
        newRect.origin.y += inset.top

        return newRect
    }
}

struct XUIBackground<Child: XUILayoutPlacable, Content: XUILayoutPlacable>: XUILayoutPlacable {
    let child: Child
    let content: Content

    func sizeThatFits(proposed: XUILayoutProposedSize, env: XUILayoutEnvironment) -> CGSize {
        content.sizeThatFits(proposed: proposed, env: env)
    }

    func placeSubviews(in bounds: CGRect, proposed: XUILayoutProposedSize, env: XUILayoutEnvironment) {
        child.placeSubviews(in: bounds, proposed: proposed, env: env)
        content.placeSubviews(in: bounds, proposed: proposed, env: env)
    }

    func addTo(parent: UIView) {
        child.addTo(parent: parent)
        content.addTo(parent: parent)
    }
}

final class XUIBox: XUIView, XUILayoutPlacable {
    let color: UIColor
    let cornerRadius: CGFloat

    init(color: UIColor, cornerRadius: CGFloat = 0) {
        self.color = color
        self.cornerRadius = cornerRadius
        super.init()
        self.backgroundColor = color
        if cornerRadius > 0 {
            self.layer.cornerRadius = cornerRadius
        }
    }

    func sizeThatFits(proposed: XUILayoutProposedSize, env: XUILayoutEnvironment) -> CGSize {
        proposed.replacingUnspecifiedDimensions(by: .zero)
    }

    func placeSubviews(in bounds: CGRect, proposed: XUILayoutProposedSize, env: XUILayoutEnvironment) {
        frame = bounds
    }

    var backingView: UIView? { self }
}

struct XUIPadding<Child: XUILayoutPlacable>: XUILayoutPlacable {
    let inset: XUIEdgeInset
    let child: Child

    func sizeThatFits(proposed: XUILayoutProposedSize, env: XUILayoutEnvironment) -> CGSize {
        let childProposal = proposed.inset(by: inset)
        let childSize = child.sizeThatFits(proposed: childProposal, env: env)
        return childSize.inset(by: inset.extent)
    }

    func placeSubviews(in bounds: CGRect, proposed: XUILayoutProposedSize, env: XUILayoutEnvironment) {
        let childProposal = proposed.inset(by: inset)
        let childSize = child.sizeThatFits(proposed: childProposal, env: env)

        print("Padding proposed:", proposed)

        let paddedBounds = bounds.inset(by: inset, layoutDirection: env.layoutDirection)
        let childFrame = CGRect(origin: paddedBounds.origin, size: childSize)
        child.placeSubviews(in: childFrame, proposed: childProposal, env: env)
    }

    func addTo(parent: UIView) {
        child.addTo(parent: parent)
    }
}

final class XUICircle: XUIView, XUILayoutPlacable {
    let color: UIColor
    init(color: UIColor) {
        self.color = color
        super.init()
        backgroundColor = .clear
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.setFillColor(color.cgColor)
        ctx.fillEllipse(in: bounds)
    }

    var backingView: UIView? { self }

    func sizeThatFits(proposed: XUILayoutProposedSize, env: XUILayoutEnvironment) -> CGSize {
        if proposed == .unspecified || proposed == .zero {
            return .zero
        }

        if proposed == .infinity {
            return CGSize(width: CGFloat.infinity, height: CGFloat.infinity)
        }

        switch (proposed.width, proposed.height) {
        case (let width?, let height?):
            let dimension = min(width, height)
            return CGSize(width: dimension, height: dimension)
        case (let width?, nil):
            return CGSize(width: width, height: width)
        case (nil, let height?):
            return CGSize(width: height, height: height)
        default:
            return .zero
        }
    }

    func placeSubviews(in bounds: CGRect, proposed: XUILayoutProposedSize, env: XUILayoutEnvironment) {
        frame = bounds
    }
}

struct XUIAlignment {
    let vertical: XUIVerticalAlignment
    let horizontal: XUIHorizontalAlignment

    static let top = XUIAlignment(vertical: .top, horizontal: .center)
    static let topLeading = XUIAlignment(vertical: .top, horizontal: .leading)
    static let topTrailing = XUIAlignment(vertical: .top, horizontal: .trailing)

    static let center = XUIAlignment(vertical: .center, horizontal: .center)
    static let leading = XUIAlignment(vertical: .center, horizontal: .leading)
    static let trailing = XUIAlignment(vertical: .center, horizontal: .trailing)

    static let bottom = XUIAlignment(vertical: .bottom, horizontal: .center)
    static let bottomLeading = XUIAlignment(vertical: .bottom, horizontal: .leading)
    static let bottomTrailing = XUIAlignment(vertical: .bottom, horizontal: .trailing)
}

enum XUIVerticalAlignment {
    case top
    case center
    case bottom
}

enum XUIHorizontalAlignment {
    case leading
    case center
    case trailing
}

struct XUIFixedFrame<Child: XUILayoutPlacable>: XUILayoutPlacable {
    var width: CGFloat
    var height: CGFloat
    var alignment: XUIAlignment
    let child: Child

    func sizeThatFits(proposed: XUILayoutProposedSize, env: XUILayoutEnvironment) -> CGSize {
        CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposed: XUILayoutProposedSize, env: XUILayoutEnvironment) {
        let childSize = child.sizeThatFits(proposed: proposed, env: env)
        var origin = bounds.origin

        switch alignment.vertical {
        case .top:
            break
        case .center:
            origin.y += (bounds.height - childSize.height) / 2
        case .bottom:
            origin.y += bounds.height - childSize.height
        }

        switch alignment.horizontal {
        case .leading:
            if env.layoutDirection == .rightToLeft {
                origin.x = bounds.maxX - childSize.width
            }
        case .center:
            origin.x += (bounds.width - childSize.width) / 2
        case .trailing:
            if env.layoutDirection == .leftToRight {
                origin.x += bounds.width - childSize.width
            }
        }
    }

    func addTo(parent: UIView) {
        child.addTo(parent: parent)
    }
}

struct XUIHStack: XUILayoutPlacable {
    var spacing: CGFloat = 8
    var alignment: XUIVerticalAlignment = .center
    let children: [XUILayoutPlacable]

    var totalSpacing: CGFloat {
        CGFloat(children.count - 1) * spacing
    }

    func availableWidth(for size: CGSize) -> CGFloat {
        size.width - totalSpacing
    }

    func childrenSizes(proposed: XUILayoutProposedSize, env: XUILayoutEnvironment) -> [CGSize] {
        if proposed == .zero || proposed == .unspecified || proposed == .infinity {
            return children.map { child in
                child.sizeThatFits(proposed: proposed, env: env)
            }
        }

        var childSizes = children.map { $0.sizeThatFits(proposed: .unspecified, env: env) }
        var idealSize = childSizes.reduce(into: CGSize.zero) { acc, size in
            acc.width += size.width
            acc.height = max(acc.height, size.height)
        }

        idealSize.width += totalSpacing

        if let proposedWidth = proposed.width, idealSize.width < proposedWidth {
            let flexibles = childSizes.enumerated().filter { childIndex, size in
                size.width == 0
            }

            var extraSpacePerChild = (proposedWidth - idealSize.width) / CGFloat(flexibles.count)

            var numAdjustedChildren: CGFloat = 0
            for (i, flexible) in flexibles {
                let newSize = children[i].sizeThatFits(
                    proposed: XUILayoutProposedSize(
                        width: flexible.width + extraSpacePerChild,
                        height: proposed.height
                    ),
                    env: env
                )

                childSizes[i] = newSize

                let consumedExtraSpace = newSize.width - flexible.width
                if consumedExtraSpace < extraSpacePerChild {
                    extraSpacePerChild += (extraSpacePerChild - consumedExtraSpace) / (CGFloat(flexibles.count) - numAdjustedChildren)
                }

                numAdjustedChildren += 1
            }
        }

        return childSizes
    }

    func sizeThatFits(proposed: XUILayoutProposedSize, env: XUILayoutEnvironment) -> CGSize {
        let sizes = childrenSizes(proposed: proposed, env: env)
        var sumSize = sizes.reduce(into: CGSize.zero) { acc, size in
            acc.width += size.width
            acc.height = max(acc.height, size.height)
        }

        sumSize.width += totalSpacing
        return sumSize
    }

    func placeSubviews(in bounds: CGRect, proposed: XUILayoutProposedSize, env: XUILayoutEnvironment) {
        let isRTL = env.layoutDirection == .rightToLeft

        var curX: CGFloat = isRTL ? bounds.maxX : bounds.minX
        let numChildren = children.count

        let sizes = childrenSizes(proposed: proposed, env: env)

        for (i, child) in children.enumerated() {
            let size = sizes[i]
            if isRTL {
                curX -= size.width
            }

            let origin = CGPoint(x: curX, y: bounds.minY)
            var frame = CGRect(origin: origin, size: size)

            positionChildFrame(&frame, in: bounds)
            let sizeProposal = XUILayoutProposedSize(size)
            child.placeSubviews(in: frame, proposed: sizeProposal, env: env)

            curX += isRTL ? 0 : size.width
            if i < numChildren - 1 {
                curX += isRTL ? -spacing : spacing
            }
        }
    }

    func positionChildFrame(_ frame: inout CGRect, in bounds: CGRect) {
        switch alignment {
        case .top:
            frame.origin.y = bounds.minY
        case .bottom:
            frame.origin.y = bounds.minY + bounds.height - frame.height
        case .center:
            frame.origin.y = bounds.minY + (bounds.height - frame.height) / 2.0
        }
    }

    func addTo(parent: UIView) {
        children.forEach { $0.addTo(parent: parent) }
    }
}

struct XUILayoutProposedSize: Equatable {
    let width: CGFloat?
    let height: CGFloat?

    static let unspecified = XUILayoutProposedSize(width: nil, height: nil)
    static let infinity = XUILayoutProposedSize(width: .infinity, height: .infinity)
    static let zero = XUILayoutProposedSize(width: 0, height: 0)

    init(width: CGFloat?, height: CGFloat?) {
        self.width = width
        self.height = height
    }

    init(_ size: CGSize) {
        self.width = size.width
        self.height = size.height
    }

    func replacingUnspecifiedDimensions(by size: CGSize) -> CGSize {
        CGSize(
            width: width ?? size.width,
            height: height ?? size.height
        )
    }

    func inset(by inset: XUIEdgeInset) -> XUILayoutProposedSize {
        let newWidth = width.map { max(0, $0 - inset.horizontal) }
        let newHeight = height.map { max(0, $0 - inset.vertical) }
        return XUILayoutProposedSize(width: newWidth, height: newHeight)
    }
}

struct XUISpacer: XUILayoutPlacable {
    var minLength: CGFloat = 0
    func sizeThatFits(proposed: XUILayoutProposedSize, env: XUILayoutEnvironment) -> CGSize {
        if proposed.width != nil {
            return CGSize(width: minLength, height: 0)
        } else if proposed.height != nil {
            return CGSize(width: 0, height: minLength)
        } else {
            return .zero
        }
    }

    func placeSubviews(in bounds: CGRect, proposed: XUILayoutProposedSize, env: XUILayoutEnvironment) {

    }
}

struct XUIVStack: XUILayoutPlacable {
    var spacing: CGFloat = 8
    var alignment: XUIHorizontalAlignment = .center
    let children: [XUILayoutPlacable]

    var totalSpacing: CGFloat {
        CGFloat(max(0, children.count - 1)) * spacing
    }

    func childrenSizes(proposed: XUILayoutProposedSize, env: XUILayoutEnvironment) -> [CGSize] {
        if proposed == .zero || proposed == .unspecified {
            return children.map { child in
                child.sizeThatFits(proposed: proposed, env: env)
            }
        }

        var childSizes = children.map { $0.sizeThatFits(proposed: .unspecified, env: env) }
        var idealSize = childSizes.reduce(into: CGSize.zero) { acc, size in
            acc.width = max(acc.width, size.width)
            acc.height += size.height
        }

        idealSize.height += totalSpacing

        if let proposedHeight = proposed.height, idealSize.height < proposedHeight {
            var extraSpacePerChild = (proposedHeight - idealSize.height) / CGFloat(children.count)

            var numAdjustedChildren: CGFloat = 0
            for (i, flexible) in childSizes.enumerated() {
                let newSize = children[i].sizeThatFits(
                    proposed: XUILayoutProposedSize(
                        width: proposed.width,
                        height: flexible.height + extraSpacePerChild
                    ),
                    env: env
                )

                childSizes[i] = newSize

                let consumedExtraSpace = newSize.height - flexible.height
                if consumedExtraSpace < extraSpacePerChild {
                    extraSpacePerChild += (extraSpacePerChild - consumedExtraSpace) / (CGFloat(children.count) - numAdjustedChildren)
                }

                numAdjustedChildren += 1
            }
        }

        return childSizes
    }

    func sizeThatFits(proposed: XUILayoutProposedSize, env: XUILayoutEnvironment) -> CGSize {
        var size = childrenSizes(proposed: proposed, env: env).reduce(into: CGSize.zero) { acc, size in
            acc.width = max(acc.width, size.width)
            acc.height += size.height
        }

        size.height += totalSpacing
        return size
    }

    func placeSubviews(in bounds: CGRect, proposed: XUILayoutProposedSize, env: XUILayoutEnvironment) {
        var curY: CGFloat = bounds.minY
        let childSizes = childrenSizes(proposed: proposed, env: env)
        
        let numChildren = children.count

        for (i, child) in children.enumerated() {
            let size = childSizes[i]
            let origin = CGPoint(x: bounds.minX, y: curY)
            var frame = CGRect(origin: origin, size: size)

            positionChildFrame(&frame, in: bounds, env: env)
            let proposedSize = XUILayoutProposedSize(size)
            child.placeSubviews(in: frame, proposed: proposedSize, env: env)

            curY += size.height
            if i < numChildren - 1 {
                curY += spacing
            }
        }
    }

    func positionChildFrame(_ frame: inout CGRect, in bounds: CGRect, env: XUILayoutEnvironment) {
        let isRTL = env.layoutDirection == .rightToLeft

        switch alignment {
        case .leading:
            frame.origin.x = isRTL ? bounds.maxX - frame.width : bounds.minX
        case .trailing:
            frame.origin.x = isRTL ? bounds.minX : bounds.minX + bounds.width - frame.width
        case .center:
            frame.origin.x = bounds.minX + (bounds.width - frame.width) / 2.0
        }
    }

    func addTo(parent: UIView) {
        children.forEach { $0.addTo(parent: parent) }
    }
}

final class XUILabel: UILabel {
    init(_ text: String) {
        super.init(frame: .zero)
        self.text = text
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension XUILabel: XUILayoutPlacable {
    var backingView: UIView? { self }

    func sizeThatFits(proposed: XUILayoutProposedSize, env: XUILayoutEnvironment) -> CGSize {
        if proposed == .unspecified || proposed == .infinity {
            return intrinsicContentSize
        }

        return self.sizeThatFits(
            proposed.replacingUnspecifiedDimensions(
                by: CGSize(
                    width: CGFloat.infinity,
                    height: CGFloat.infinity
                )
            )
        )
    }

    func placeSubviews(in bounds: CGRect, proposed: XUILayoutProposedSize, env: XUILayoutEnvironment) {
        frame = bounds
    }
}

extension UIButton: XUILayoutPlacable {
    var backingView: UIView? { self }

    func sizeThatFits(proposed: XUILayoutProposedSize, env: XUILayoutEnvironment) -> CGSize {
        if proposed == .unspecified || proposed == .infinity {
            return intrinsicContentSize
        }

        return self.sizeThatFits(
            proposed.replacingUnspecifiedDimensions(
                by: CGSize(
                    width: CGFloat.infinity,
                    height: CGFloat.infinity
                )
            )
        )
    }

    func placeSubviews(in bounds: CGRect, proposed: XUILayoutProposedSize, env: XUILayoutEnvironment) {
        frame = bounds
    }
}

func XUIButton(_ title: String, action: @escaping () -> Void) -> UIButton {
    UIButton(type: .system, primaryAction: UIAction(title: title) { _ in action() })
}
