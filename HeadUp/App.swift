//
//  HeadUpApp.swift
//  HeadUp
//
//  Created by Ivan Kh on 18.12.2025.
//

import SwiftUI
import SystemExtensions
import hupSplitView
import hupApplicationsList
import ComposableArchitecture

@main
struct HeadUpApp: App {
    var body: some Scene {
        WindowGroup {
            SplitView(.init(initialState: .init()) {
                SplitFeature()
            })
        }
    }
}
