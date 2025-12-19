//
//  Applications.View.swift
//  HeadUp
//
//  Created by Ivan Kh on 18.12.2025.
//

import SwiftUI
import ComposableArchitecture
import hupCommon

public struct ApplicationsView: View {
    let store: StoreOf<Applications>

    public init(_ store: StoreOf<Applications>) {
        self.store = store
    }
    
    public var body: some View {
        ScrollView {
            ForEach(store.applications) { application in
                HStack {
                    Button("Block") {
                        store.send(.block(application))
                    }

                    if let icon = application.icon {
                        Image(nsImage: icon)
                    }
                    
                    Text(application.name)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.bottom, 1)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .task {
            store.send(.loadApplications, animation: .default)
        }
    }
}

