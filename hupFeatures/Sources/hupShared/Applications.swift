//
//  Applications.swift
//  hupFeatures
//
//  Created by Ivan Kh on 03.01.2026.
//

import ComposableArchitecture
import SwiftUI

public struct ApplicationInfo: Identifiable, Equatable, Sendable, Hashable {
    public let id: String
    public let name: String
    public let icon: NSImage?
}

@DependencyClient
public struct ApplicationsClient: Sendable {
    public var running: @Sendable () async -> [ApplicationInfo] = {[]}
}

extension ApplicationsClient: DependencyKey {
    public static var liveValue: ApplicationsClient {
        return .init {
            NSWorkspace.shared.runningApplicationsInfo
        }
    }
}

public extension DependencyValues {
    var applications: ApplicationsClient {
        get { self[ApplicationsClient.self] }
        set { self[ApplicationsClient.self] = newValue }
    }
}

private extension NSRunningApplication {
    var name: String? {
        localizedName ?? executableURL?.lastPathComponent
    }
}

extension NSWorkspace {
    var runningApplicationsInfo: [ApplicationInfo] {
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
