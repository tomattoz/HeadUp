//
//  ContentView.swift
//  HeadUp
//
//  Created by Ivan Kh on 18.12.2025.
//

import SwiftUI
import ComposableArchitecture
import hupUI
import hupCommon

struct ContentView: View {
    private let blocker: BlockerActor
    
    init(blocker: BlockerProtocol) {
        self.blocker = .init(blocker)
    }
    
    var body: some View {
        VStack {
            ApplicationsView(.init(initialState: .init(), reducer: {
                Applications()
            }, withDependencies: { dependencies in
                dependencies.blocker = BlockerClient(blocker)
            }))
        }
        .padding()
    }
}

private actor BlockerActor {
    let inner: BlockerProtocol
    
    init(_ blocker: BlockerProtocol) {
        self.inner = blocker
    }
    
    func blockApplication(withName name: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            inner.blockApplication(withName: name) { error in
                if let error {
                    continuation.resume(throwing: error)
                }
                else {
                    continuation.resume()
                }
            }
        } as Void
    }
}

private extension BlockerClient {
    init(_ inner: BlockerActor) {
        self.init { applicationName in
            try await inner.blockApplication(withName: applicationName)
        }
    }
}

#if DEBUG
private class BlockerStub: BlockerProtocol {
    func blockApplication(withName name: String, callback: @escaping (NSError?) -> Void) {
        callback(nil)
    }
}
#Preview {
    ContentView(blocker: BlockerStub())
}
#endif
