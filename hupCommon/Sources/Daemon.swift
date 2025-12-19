//
//  Daemon.swift
//  hupCommon
//
//  Created by Ivan Kh on 19.12.2025.
//

import SystemExtensions

public extension String {
    static let endpointSecurityDaemonID = "com.ihvorostinin.headup.daemon"
}

public class EnpointSecurityDaemon {
    public init() {
        
    }
    
    public func run(_ delegate: OSSystemExtensionRequestDelegate) {
        let request = OSSystemExtensionRequest.activationRequest(
            forExtensionWithIdentifier: .endpointSecurityDaemonID,
            queue: .main)
        
        request.delegate = delegate
        OSSystemExtensionManager.shared.submitRequest(request)
    }
}
