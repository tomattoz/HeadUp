//
//  Main.Reducer.swift
//  hupUI
//
//  Created by Ivan Kh on 02.01.2026.
//

import SwiftUI
import Combine
import ComposableArchitecture
import hupApplicationsList
import hupApplicationDetails
import hupShared
import hupUtils

@Reducer
public struct SplitFeature {
    public init() {}

    @Dependency(\.blocker) var blocker

    public struct State: Equatable {
        public init() {}

        var master: ApplicationsListFeature.State = .init()
        @PresentationState var detail: ApplicationDetailsFeature.State? = nil
    }
    
    public enum Action {
        case master(ApplicationsListFeature.Action)
        case detail(PresentationAction<ApplicationDetailsFeature.Action>)
        case setDetail(ApplicationDetailsFeature.State)
    }
    
    enum CancelID: Hashable {
        case counter
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \ .master, action: \ .master) {
            ApplicationsListFeature()
        }
        
        .ifLet(\.$detail, action: \ .detail) {
            ApplicationDetailsFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .master(.setSelection(let application)):
                let blocker = blocker
                return .merge(
                    .run { send in
                        await send(.setDetail(.init(
                            application,
                            blocked: blocker.blocked(application),
                            blocksCount: blocker.blocksCount(application))))
                    },
                    .cancel(id: CancelID.counter),
                    .run { send in
                        guard let stream = await blocker.counterStream(application) else { return }
                        
                        for await item in stream {
                            await send(.setDetail(.init(
                                application,
                                blocked: blocker.blocked(application),
                                blocksCount: item.count)))
                        }
                    }
                    .cancellable(id: CancelID.counter, cancelInFlight: true)
                )
                
            case .setDetail(let value):
                state.detail = value
                return .none

            case .master, .detail:
                return .none
            }
        }
    }
}
