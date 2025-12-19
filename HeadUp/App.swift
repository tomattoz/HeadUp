//
//  HeadUpApp.swift
//  HeadUp
//
//  Created by Ivan Kh on 18.12.2025.
//

import SwiftUI
import SystemExtensions
import hupCommon

@main
struct HeadUpApp: App {
    private let daemon = EnpointSecurityDaemon()
    private let daemonDelegate = SystemExtensionDelegate()
    private let blocker = XPCClient()
    
    init() {
        daemon.run(daemonDelegate)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(blocker: blocker)
        }
    }
}

private final class SystemExtensionDelegate: NSObject, OSSystemExtensionRequestDelegate {
    static let shared = SystemExtensionDelegate()

    func request(_ request: OSSystemExtensionRequest, didFinishWithResult result: OSSystemExtensionRequest.Result) {
        print("System extension request finished with result: \(result.rawValue)")
    }

    func request(_ request: OSSystemExtensionRequest, didFailWithError error: Error) {
        print("System extension request failed with error: \(error.localizedDescription)")
    }

    func requestNeedsUserApproval(_ request: OSSystemExtensionRequest) {
        print("System extension request needs user approval")
    }

    func request(_ request: OSSystemExtensionRequest, actionForReplacingExtension existing: OSSystemExtensionProperties, withExtension replacement: OSSystemExtensionProperties) -> OSSystemExtensionRequest.ReplacementAction {
        return .replace
    }
}
