//
//  Blocker.swift
//  HeadUp
//
//  Created by Ivan Kh on 18.12.2025.
//

import Foundation
import EndpointSecurity
import hupCommon

public final class Blocker: BlockerProtocol {
    private var client: OpaquePointer?
    private var blockedAppNames = Set<String>()

    public init() {}

    public func blockApplication(withName name: String, callback: @escaping (NSError?) -> Void) {
        blockedAppNames.insert(name)
        callback(nil)
    }

    public func setup() {
        // Create client with callback.
        let callback: es_handler_block_t = { [self] (clientPtr, messagePtr) in
            handle(messagePtr, client: clientPtr)
        }

        var localClient: OpaquePointer? = nil
        let createResult = es_new_client(&localClient, callback)
        guard createResult == ES_NEW_CLIENT_RESULT_SUCCESS, let created = localClient else {
            print("Failed to create Endpoint Security client: \(createResult)")
            return
        }
        self.client = created

        // Subscribe to AUTH EXEC events so we can allow/deny.
        let events: [es_event_type_t] = [ES_EVENT_TYPE_AUTH_EXEC]
        let subResult: es_return_t = events.withUnsafeBufferPointer { buf in
            guard let base = buf.baseAddress, buf.count > 0 else {
                return ES_RETURN_ERROR
            }
            return es_subscribe(created, base, UInt32(buf.count))
        }
        guard subResult == ES_RETURN_SUCCESS else {
            print("Failed to subscribe to AUTH EXEC events: \(subResult)")
            return
        }

        print("EndpointSecurity client initialized and subscribed to AUTH EXEC events.")
    }

    public func tearDown() {
        if let c = client {
            es_unsubscribe_all(c)
            es_delete_client(c)
            client = nil
        }
    }

    private func handle(_ message: UnsafePointer<es_message_t>, client: OpaquePointer?) {
        let msg = message.pointee

        switch msg.event_type {
        case ES_EVENT_TYPE_AUTH_EXEC:
            let execEvent = msg.event.exec

            // not sure path here or file name, so maybe we have to take lastPathComponent here
            var execPath = ""
            if let ptr = execEvent.target.pointee.executable.pointee.path.data {
                execPath = String(cString: ptr)
            }

            if blockedAppNames.contains(execPath) {
                if let c = client {
                    es_respond_auth_result(c, message, ES_AUTH_RESULT_DENY, true)
                    print("Blocked \(execPath)")
                }
            } else {
                if let c = client {
                    es_respond_auth_result(c, message, ES_AUTH_RESULT_ALLOW, true)
                }
            }

        default:
            // Ignore other events
            break
        }
    }
}
