//
//  Applications.View.swift
//  HeadUp
//
//  Created by Ivan Kh on 18.12.2025.
//

import SwiftUI
import ComposableArchitecture

public struct ApplicationsListView: View {
    let store: StoreOf<ApplicationsListFeature>

    public init(_ store: StoreOf<ApplicationsListFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack {
                        ForEach(viewStore.applications) { application in
                            HStack {
                                if let icon = application.icon {
                                    Image(nsImage: icon)
                                }
                                
                                Text(application.name)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .id(application.id)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        .selection
                                        .opacity(application == viewStore.selected ? 1 : 0.001))
                            )
                            .padding(.bottom, 1)
                            .onTapGesture {
                                viewStore.send(.setSelection(application))
                            }
                            .onAppear {
                                viewStore.send(.setVisible(application, true))
                            }
                            .onDisappear {
                                viewStore.send(.setVisible(application, false))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                    .enableNavigation(viewStore)
                }
                .task {
                    viewStore.send(.loadApplications)
                }
                .onChange(of: viewStore.selected) { newSelection in
                    guard let selected = newSelection else { return }
                    guard !viewStore.visibleApplications.contains(selected) else { return }

                    withAnimation {
                        proxy.scrollTo(selected.id)
                    }
                }
            }
        }
    }
}

private extension View {
    @ViewBuilder func enableNavigation(_ viewStore: ViewStoreOf<ApplicationsListFeature>) -> some View {
        if #available(macOS 14.0, *) {
            self
                .focusable()
                .focusEffectDisabled(true)
                .onMoveCommand { direction in
                    switch direction {
                    case .down:
                        viewStore.send(.moveSelectionDown)
                    case .up:
                        viewStore.send(.moveSelectionUp)
                    default:
                        break
                    }
                }
        } else {
            self
        }
    }
}
