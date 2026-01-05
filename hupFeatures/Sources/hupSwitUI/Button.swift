//
//  Untitled.swift
//  hupFeatures
//
//  Created by Ivan Kh on 04.01.2026.
//

import SwiftUI

public extension View {    
    @ViewBuilder func buttonStyleGlassProminentIfSupported() -> some View {
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            self.buttonStyle(.glassProminent)
        } else {
            self
        }
    }
}
