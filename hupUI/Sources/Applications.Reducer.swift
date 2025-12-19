//
//  Applications.Reducer.swift
//  HeadUp
//
//  Created by Ivan Kh on 18.12.2025.
//

import SwiftUI
import Combine
import ComposableArchitecture
import hupCommon

@Reducer
public struct Applications {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        var applications = [TheRunningApplication]()
        public init() {}
    }
    
    public enum Action {
        case loadApplications
        case setApplications([TheRunningApplication])
        case block(TheRunningApplication)
    }
    
    struct Feature {
        @Dependency(\.blocker) var blocker
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .loadApplications:
                return .run { send in
                    await send(.setApplications(NSWorkspace.shared.theRunningApplication))
                }
            case .setApplications(let apps):
                state.applications = apps
                return .none
            case .block(let application):
                return .run { [application] _ in
                    do {
                        try await Feature().blocker.blockApplicationByName(application.name)
                        print("Application \(application.name) has been blocked")
                    }
                    catch {
                        print("Application \(application.name) failed to be blocked:\n\(error)")
                    }
                }
            }
        }
    }
}

public struct BlockerClient : Sendable{
    var blockApplicationByName: @Sendable (String) async throws -> Void
    
    public init(blockApplicationByName: @Sendable @escaping (String) async throws -> Void) {
        self.blockApplicationByName = blockApplicationByName
    }
}

extension BlockerClient: DependencyKey {
    public static var liveValue: BlockerClient {
        BlockerClient { _ in }
    }
}

extension DependencyValues {
    public var blocker: BlockerClient {
        get { self[BlockerClient.self] }
        set { self[BlockerClient.self] = newValue }
    }
}

public struct TheRunningApplication: Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let icon: NSImage?
}

private extension NSRunningApplication {
    var name: String? {
        localizedName ?? executableURL?.lastPathComponent
    }
}

private extension NSWorkspace {
    var theRunningApplication: [TheRunningApplication] {
        runningApplications
            .filter {
                $0.activationPolicy == .regular
            }
            .compactMap {
                guard
                    let id = $0.bundleIdentifier,
                    let name = $0.name
                else { return nil }
                
                return .init(id: id, name: name, icon: $0.icon)
            }
    }
}
