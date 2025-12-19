//
//  main.swift
//  com.ihvorostinin.headup.daemon
//
//  Created by Ivan Kh on 18.12.2025.
//

import Foundation
import EndpointSecurity
import hupCommon
import hupDaemon

let blocker = Blocker()
let xpcListener = NSXPCListener.service()
let xpcService = XPCService(blocker)

blocker.setup()
xpcListener.delegate = xpcService
xpcListener.resume()

dispatchMain()

