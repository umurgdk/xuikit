//  Created by Umur Gedik on 27.07.2023.

import SwiftUI

#if os(macOS)
public typealias XUINativeColor = NSColor
let cirNativeDarkBackgroundColor = NSColor(white: 0.08, alpha: 1.0)
#else
public typealias XUINativeColor = UIColor
let cirNativeDarkBackgroundColor = UIColor.black
#endif

@propertyWrapper
public struct XUIThemeColors: DynamicProperty {
    public let inverse: Bool

    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(\.xuiTheme)
    private var theme

    public var wrappedValue: XUITheme.Colors {
        if inverse {
            return colorScheme == .dark ? theme.light : theme.dark
        } else {
            return colorScheme == .dark ? theme.dark : theme.light
        }
    }

    public init(inverse: Bool = false) {
        self.inverse = inverse
    }
}

extension Color {
    init(native: XUINativeColor) {
        #if os(macOS)
        self.init(nsColor: native)
        #else
        self.init(uiColor: native)
        #endif
    }
}

public struct XUITheme: Equatable {
    public struct Colors: Equatable {
        public let primary: Color
        public let secondary: Color
        public let tertiary: Color
        public let separator: Color
        public let background: Color
        public let backgroundSecondary: Color

        public let native: NativeColors

        public init(
            primary: XUINativeColor,
            secondary: XUINativeColor,
            tertiary: XUINativeColor,
            separator: XUINativeColor,
            background: XUINativeColor,
            backgroundSecondary: XUINativeColor
        ) {
            self.native = NativeColors(
                primary: primary,
                secondary: secondary,
                tertiary: tertiary,
                separator: separator,
                background: background,
                backgroundSecondary: backgroundSecondary
            )
            
            self.primary = Color(native: primary)
            self.secondary = Color(native: secondary)
            self.tertiary = Color(native: tertiary)
            self.separator = Color(native: separator)
            self.background = Color(native: background)
            self.backgroundSecondary = Color(native: backgroundSecondary)
        }
    }

    public struct NativeColors: Equatable {
        public let primary: XUINativeColor
        public let secondary: XUINativeColor
        public let tertiary: XUINativeColor
        public let separator: XUINativeColor
        public let background: XUINativeColor
        public let backgroundSecondary: XUINativeColor
    }

    public let light: Colors
    public let dark: Colors
    public let native: NativeColors

    public static let `default` = XUITheme(
        light: Colors(
            primary: XUINativeColor.black,
            secondary: XUINativeColor(hue: 0, saturation: 0, brightness: 0.4, alpha: 1),
            tertiary: XUINativeColor(white: 0.6, alpha: 1.0),
            separator: XUINativeColor(white: 0.9, alpha: 1.0),
            background: XUINativeColor.white,
            backgroundSecondary: XUINativeColor(white: 0.96, alpha: 1)
        ),
        dark: Colors(
            primary: XUINativeColor.white,
            secondary: XUINativeColor(hue: 0, saturation: 0, brightness: 0.4, alpha: 1),
            tertiary: XUINativeColor(white: 0.4, alpha: 1.0),
            separator: XUINativeColor(white: 0.1, alpha: 1.0),
            background: XUINativeColor.black,
            backgroundSecondary: XUINativeColor(white: 0.05, alpha: 1)
        )
    )

    public init(light: Colors, dark: Colors) {
        self.light = light
        self.dark = dark

        self.native = NativeColors(
            primary: dynamic(light: light.native.primary, dark: dark.native.primary),
            secondary: dynamic(light: light.native.secondary, dark: dark.native.secondary),
            tertiary: dynamic(light: light.native.tertiary, dark: dark.native.tertiary),
            separator: dynamic(light: light.native.separator, dark: dark.native.separator),
            background: dynamic(light: light.native.background, dark: dark.native.background),
            backgroundSecondary: dynamic(light: light.native.backgroundSecondary, dark: dark.native.backgroundSecondary)
        )
    }
}

private func dynamic(light: XUINativeColor, dark: XUINativeColor) -> XUINativeColor {
    UIColor { traitCollection in
        if traitCollection.userInterfaceStyle == .dark {
            return dark
        }

        return light
    }
}

private struct XUIThemeKey: EnvironmentKey {
    static let defaultValue = XUITheme.default
}

public extension EnvironmentValues {
    var xuiTheme: XUITheme {
        get { self[XUIThemeKey.self] }
        set { self[XUIThemeKey.self] = newValue }
    }
}
