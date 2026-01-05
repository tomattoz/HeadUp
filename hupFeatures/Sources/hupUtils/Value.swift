//
//  Value.swift
//  hupUtils
//
//  Created by Ivan Kh on 05.01.2026.
//

@propertyWrapper
public class BoxedVar<Value> {
    public var wrappedValue: Value
    
    public init(_ value: Value) {
        self.wrappedValue = value
    }
    
    public var value: Value {
        get { wrappedValue }
        set { wrappedValue = newValue }
    }
}

extension BoxedVar: Equatable where Value: Equatable {
    public static func == (lhs: BoxedVar<Value>, rhs: BoxedVar<Value>) -> Bool {
        lhs.value == rhs.value
    }
}
