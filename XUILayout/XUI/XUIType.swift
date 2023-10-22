//  Created by Umur Gedik on 4.10.2023.

import SwiftUI

struct CIRType {
    let font: Font
    var color: Color? = nil
    var kerning: CGFloat = 0

    static let title = CIRType(
        font: .system(
            size: 24,
            weight: .semibold,
            design: .rounded
        )
    )

    static let subtitle = CIRType(
        font: .system(
            size: 16,
            weight: .medium,
            design: .rounded
        )
    )
    
    static let body = CIRType(
        font: .system(
            size: 16,
            weight: .medium,
            design: .rounded
        )
    )
    
    static let bodySecondary = CIRType(
        font: .system(
            size: 16,
            weight: .regular,
            design: .rounded
        )
    )
    
    static let caption = CIRType(
        font: .system(
            size: 14,
            weight: .medium,
            design: .rounded
        )
    )

    static let buttonLabel = CIRType(
        font: .system(
            size: 17,
            weight: .medium,
            design: .rounded
        )
    )

    static let inputLarge = CIRType(
        font: .system(
            size: 32,
            weight: .semibold,
            design: .rounded
        )
    )
    
    static let sectionTitle = CIRType(
        font: .system(
            size: 18,
            weight: .medium,
            design: .rounded
        )
    )

    static let circlePickerName = CIRType(
        font: .system(
            size: 20,
            weight: .medium,
            design: .rounded
        )
    )

    static let sectionSubtitle = CIRType(
        font: .system(
            size: 14,
            weight: .medium,
            design: .rounded
        ),
        color: .secondary
    )
}

extension View {
    func cirTypography(_ type: CIRType) -> Text where Self == Text {
        self.font(type.font).kerning(type.kerning)
    }
    
    func cirTypography(_ type: CIRType) -> some View {
        self.font(type.font)
    }
}

extension UIFont {
    static func rounded(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        let font: UIFont

        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            font = UIFont(descriptor: descriptor, size: size)
        } else {
            font = systemFont
        }
        return font
    }
}
