//
//  Main.View.swift
//  hupUI
//
//  Created by Ivan Kh on 02.01.2026.
//

import SwiftUI
import ComposableArchitecture
import hupApplicationsList
import hupApplicationDetails

public struct SplitView: View {
    let store: StoreOf<SplitFeature>
    
    public init(_ store: StoreOf<SplitFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationSplitView {
            let store = self.store.scope(state: \.master, action: \.master)
            ApplicationsListView(store)
                .padding(.horizontal)
        } detail: {
            IfLetStore(
                self.store.scope(state: \.$detail, action: \.detail)
            ) { detailStore in
                ApplicationDetailsView(detailStore)
            } else: {
                EmptyView()
            }
        }
    }
}

