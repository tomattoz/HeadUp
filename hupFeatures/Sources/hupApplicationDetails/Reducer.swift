//
//  Reducer.swift
//  hupFeatures
//
//  Created by Ivan Kh on 03.01.2026.
//

import ComposableArchitecture
import hupShared
import SwiftUI
import Combine
import hupUtils

@Reducer
public struct ApplicationDetailsFeature {
    @Dependency(\.blocker) var blocker

    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        public let application: ApplicationInfo
        public var blocked: Bool
        public var blocksCount: UInt = 0
        
        public init(_ application: ApplicationInfo, blocked: Bool, blocksCount: UInt) {
            self.application = application
            self.blocked = blocked
            self.blocksCount = blocksCount
        }
    }
    
    public enum Action {
        case block(ApplicationInfo)
        case unblock(ApplicationInfo)
        case setBlocked(ApplicationInfo, Bool)
        case setCounter(UInt)
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .setBlocked(let application, let value):
                state.blocked = value
                return .run { send in
                    if value {
                        await send(.block(application))
                    }
                    else {
                        await send(.unblock(application))
                    }
                }
            
            case .block(let application):
                let blocker = blocker
                return .run { send in
                    await blocker.block(application)
                }
                
            case .unblock(let application):
                let blocker = blocker
                return .run { send in
                    await blocker.unblock(application)
                    await send(.setCounter(0))
                }
                                
            case .setCounter(let value):
                state.blocksCount = value
                return .none
            }
        }
    }
}

