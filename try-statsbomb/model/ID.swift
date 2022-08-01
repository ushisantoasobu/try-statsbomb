//
//  ID.swift
//  try-statsbomb
//
//  Created by Shunsuke Sato on 2022/07/27.
//

import Foundation

struct Identifier<Identified, Value>: RawRepresentable {
    typealias RawValue = Value

    let rawValue: Value

    init(rawValue: Value) {
        self.rawValue = rawValue
    }
}

extension Identifier: Decodable where Value: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(Value.self)
        self.rawValue = value
    }
}

extension Identifier: Equatable where Value: Equatable {}
extension Identifier: Hashable where Value: Hashable {}

extension Identifier: ExpressibleByIntegerLiteral where RawValue: ExpressibleByIntegerLiteral {
    init(integerLiteral value: RawValue.IntegerLiteralType) {
        self.init(rawValue: RawValue(integerLiteral: value))
    }
}

// MEMO: idは文字列のもある
extension Identifier: ExpressibleByUnicodeScalarLiteral where RawValue: ExpressibleByUnicodeScalarLiteral {

    init(unicodeScalarLiteral value: RawValue.UnicodeScalarLiteralType) {
        self.init(rawValue: RawValue(unicodeScalarLiteral: value))
    }
}

extension Identifier: ExpressibleByExtendedGraphemeClusterLiteral where RawValue: ExpressibleByExtendedGraphemeClusterLiteral {
    init(extendedGraphemeClusterLiteral value: RawValue.ExtendedGraphemeClusterLiteralType) {
        self.init(rawValue: RawValue(extendedGraphemeClusterLiteral: value))
    }
}

extension Identifier: ExpressibleByStringLiteral where RawValue: ExpressibleByStringLiteral {
    init(stringLiteral value: RawValue.StringLiteralType) {
        self.init(rawValue: RawValue(stringLiteral: value))
    }
}
