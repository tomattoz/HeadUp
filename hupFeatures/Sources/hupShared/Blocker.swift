//
//  Blocker.swift
//  hupUI
//
//  Created by Ivan Kh on 30.12.2025.
//

import Foundation
import Combine
import ComposableArchitecture
import SwiftUI

public actor Blocker: ObservableObject {
    public struct BlocksCount: Sendable {
        public let application: ApplicationInfo
        public let count: UInt
    }
    
    @Published private(set) var counter = [ApplicationInfo: UInt]()
    private var blocked = [ApplicationInfo]()
    private var timer: Task<Void, Never>?
    private var streams = [ApplicationInfo: ApplicationStream]()
    
    public func start() {
        self.timer = Task(priority: .utility) { [weak self] in
            while !Task.isCancelled {
                guard let self else { return }
                await self.process()
                try? await Task.sleep(for: .seconds(1))
            }
        }
    }
    
    public func blocked(_ application: ApplicationInfo) async -> Bool {
        blocked.contains(where: { $0.id == application.id })
    }
    
    public func block(_ application: ApplicationInfo) async {
        counter[application] = 0
        blocked.append(application)
    }
    
    public func unblock(_ application: ApplicationInfo) async {
        blocked.removeAll { $0.id == application.id }
    }
    
    public func blocksCount(_ application: ApplicationInfo) async -> UInt {
        counter[application] ?? 0
    }
    
    public func counterStream(_ application: ApplicationInfo) async -> AsyncStream<BlocksCount> {
        let result = AsyncStream.makeStream(of: BlocksCount.self)
        streams[application] = .init(result)
        return result.stream
    }
}

@DependencyClient
public struct BlockerClient: Sendable {
    public var blocked: @Sendable (ApplicationInfo) async -> Bool = { _ in false }
    public var blocksCount: @Sendable (ApplicationInfo) async -> UInt = { _ in 0 }
    public var counterStream: @Sendable (ApplicationInfo) async -> AsyncStream<Blocker.BlocksCount>?
    public var block: @Sendable (ApplicationInfo) async -> Void = { _ in }
    public var unblock: @Sendable (ApplicationInfo) async -> Void = { _ in }
}

extension BlockerClient: DependencyKey {
    public static var liveValue: BlockerClient {
        let blocker = Blocker()
        Task { await blocker.start() }
        return BlockerClient(blocked: blocker.blocked,
                             blocksCount: blocker.blocksCount,
                             counterStream: blocker.counterStream,
                             block: blocker.block,
                             unblock: blocker.unblock)
    }
}

public extension DependencyValues {
    var blocker: BlockerClient {
        get { self[BlockerClient.self] }
        set { self[BlockerClient.self] = newValue }
    }
}

private extension Blocker {
    struct ApplicationStream {
        let stream: AsyncStream<BlocksCount>
        let continuation: AsyncStream<BlocksCount>.Continuation
        
        init(_ src: (AsyncStream<BlocksCount>, AsyncStream<BlocksCount>.Continuation)) {
            stream = src.0
            continuation = src.1
        }
    }
    
    func process() {
        let blocked = Set<ApplicationInfo>(blocked)
        let pairs: [(NSRunningApplication, ApplicationInfo)] = NSWorkspace.shared
            .runningApplications
            .filter { $0.isActive }
            .compactMap { app in
                guard let bundleID = app.bundleIdentifier,
                      let info = blocked.first(where: { $0.id == bundleID })
                else { return nil }
                return (app, info)
            }

        for (app, info) in pairs {
            let count = (counter[info] ?? 0) + 1
            app.hide()
            counter[info] = count
            streams[info]?.continuation.yield(.init(application: info, count: count))
        }
    }
}
