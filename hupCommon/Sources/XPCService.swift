//
//  XPCService.swift
//  hupCommon
//
//  Created by Ivan Kh on 19.12.2025.
//

import Foundation

public final class XPCService: NSObject, NSXPCListenerDelegate {
    private let exportedObject: BlockerProtocol
    
    public init(_ blocker: BlockerProtocol) {
        self.exportedObject = blocker
    }

    public func listener(_ listener: NSXPCListener,
                         shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        newConnection.exportedInterface = NSXPCInterface(with: BlockerProtocol.self)
        newConnection.exportedObject = exportedObject
        newConnection.resume()
        return true
    }
}
