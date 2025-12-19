//
//  XPCClient.swift
//  hupCommon
//
//  Created by Ivan Kh on 19.12.2025.
//

import Foundation

private enum SecurityDaemonError: Error {
    case uknownDaemonType
}

public final class XPCClient: BlockerProtocol {
    private var connection: NSXPCConnection?

    public init() {
    }
    
    private func connectionOrCreate() -> NSXPCConnection {
        if let connection { return connection }
        let connection = NSXPCConnection(machServiceName: .endpointSecurityDaemonID,
                                         options: .privileged)
        
        connection.remoteObjectInterface = NSXPCInterface(with: BlockerProtocol.self)
        
        connection.invalidationHandler = { [weak self] in
            print("XPC connection invalidated")
            self?.connection = nil
        }
        connection.interruptionHandler = {
            print("XPC connection interrupted")
        }
        
        connection.resume()
        self.connection = connection
       
        return connection
    }

    public func blockApplication(withName name: String, callback: @escaping (NSError?) -> Void) {
        let conn = connectionOrCreate()
        
        guard let proxy = conn.remoteObjectProxyWithErrorHandler({ error in
            callback(error as NSError)
        }) as? BlockerProtocol else {
            callback(SecurityDaemonError.uknownDaemonType as NSError)
            return
        }
        
        proxy.blockApplication(withName: name, callback: callback)
    }
}
