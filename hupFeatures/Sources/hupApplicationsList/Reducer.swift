//
//  Applications.Reducer.swift
//  HeadUp
//
//  Created by Ivan Kh on 18.12.2025.
//

import SwiftUI
import Combine
import ComposableArchitecture
import hupShared
import hupUtils

@Reducer
public struct ApplicationsListFeature {
    public init() {}
    
    @Dependency(\.applications) var applications
    @Dependency(\.blocker) var blocker

    @ObservableState
    public struct State: Equatable {
        var applications = [ApplicationInfo]()
        var visibleApplications: Set<ApplicationInfo> = []
        var selected: ApplicationInfo?
        public init() {}
    }
    
    public enum Action {
        case loadApplications
        case setApplications([ApplicationInfo])
        case setSelection(ApplicationInfo)
        case setVisible(ApplicationInfo, Bool)
        case block(ApplicationInfo)
        case moveSelectionDown
        case moveSelectionUp
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .loadApplications:
                let applications = self.applications
                return .run { send in
                    let apps = await applications.running()
                    await send(.setApplications(apps))
                }
          
            case .setApplications(let apps):
                state.applications = apps

                if state.selected == nil, let first = apps.first {
                    return .run { send in
                        await send(.setSelection(first))
                    }
                }
                else {
                    return .none
                }
          
            case .setSelection(let app):
                state.selected = app
                return .none
           
            case .setVisible(let app, let visible):
                if visible {
                    state.visibleApplications.insert(app)
                }
                else {
                    state.visibleApplications.remove(app)
                }
                return .none

            case .block(let application):
                let blocker = self.blocker
                return .run { [blocker] _ in
                    await blocker.block(application)
                }
           
            case .moveSelectionDown:
                if let application = state.selected,
                   let idx = state.applications.firstIndex(of: application) {
                    let nextIndex = min(idx + 1, state.applications.count - 1)
                    state.selected = state.applications[nextIndex]
                }
                return .none
                
            case .moveSelectionUp:
                if let application = state.selected,
                   let idx = state.applications.firstIndex(of: application) {
                    let prevIndex = max(idx - 1, 0)
                    state.selected = state.applications[prevIndex]
                }
                return .none
            }
        }
    }
}

