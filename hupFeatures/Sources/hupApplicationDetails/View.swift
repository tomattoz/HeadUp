//
//  View.swift
//  hupFeatures
//
//  Created by Ivan Kh on 03.01.2026.
//

import ComposableArchitecture
import SwiftUI
import hupSwitUI

public struct ApplicationDetailsView: View {
    let store: StoreOf<ApplicationDetailsFeature>
    
    public init(_ store: StoreOf<ApplicationDetailsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                if let icon = viewStore.application.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 128)
                }
                
                Text(viewStore.application.name)
                
                if viewStore.blocked {
                    Text("Blocks count: \(viewStore.blocksCount)")
                }
                else {
                    Text(" ")
                }
            }
            .padding(.top, -32)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    BlockButton(viewStore: viewStore)
                }
            }
        }
    }
}

private struct BlockButton: View {
    let viewStore: ViewStoreOf<ApplicationDetailsFeature>
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Toggle(isOn: blocked) {
            HStack {
                Icon()
                    .padding(.top, -3)
                    .frame(width: 18, alignment: .leading)
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.trailing, 6)
            .frame(width: 90)
        }
        .toggleStyle(.button)
        .buttonStyleGlassProminentIfSupported()
        .tint(tint)
    }

    func Icon() -> some View {
        Image(systemName: viewStore.blocked ? "lock.open.fill" : "lock.fill")
            .padding(.leading, viewStore.blocked ? 0.5 : 0)
    }
    
    var title: String {
        viewStore.blocked ? "Unblock" : "Block"
    }
    
    var tint: Color {
        if colorScheme == .dark {
            viewStore.blocked ? .red.opacity(0.1) : .blue.opacity(0.2)
        }
        else {
            viewStore.blocked ? .red.opacity(0.5) : .blue.opacity(0.7)
        }
    }
    
    var blocked: Binding<Bool> {
        viewStore.binding(
            get: \.blocked,
            send: { .setBlocked($0) }
        )
    }
}

