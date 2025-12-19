//
//  Blocker.swift
//  HeadUp
//
//  Created by Ivan Kh on 18.12.2025.
//

import Foundation

@objc public protocol BlockerProtocol {
    func blockApplication(withName name: String, callback: @escaping (NSError?) -> Void)
}
