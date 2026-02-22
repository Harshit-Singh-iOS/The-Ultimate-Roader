//
//  FirebaseCodable.swift
//  Ultimate Roader
//

import Foundation
import FirebaseDatabase

enum FirebaseCodable {
    static func decode<T: Decodable>(_ type: T.Type, from snapshot: DataSnapshot) throws -> T {
        guard let value = snapshot.value else {
            throw DecodingError.valueNotFound(
                AnyCodable.self,
                .init(codingPath: [], debugDescription: "Snapshot has no value.")
            )
        }
        return try decode(type, from: value)
    }

    static func decode<T: Decodable>(_ type: T.Type, from dictionary: [String: Any]) throws -> T {
        return try decode(type, from: dictionary as Any)
    }

    static func decode<T: Decodable>(_ type: T.Type, from value: Any) throws -> T {
        let jsonData = try JSONSerialization.data(withJSONObject: value, options: [])
        return try makeDecoder().decode(T.self, from: jsonData)
    }

    static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()

            if let stringValue = try? container.decode(String.self) {
                if let date = ISO8601DateFormatter().date(from: stringValue) {
                    return date
                }
                if let epoch = Double(stringValue) {
                    return Date(timeIntervalSince1970: epoch)
                }
            }

            if let epoch = try? container.decode(Double.self) {
                return Date(timeIntervalSince1970: epoch)
            }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported date value.")
        }
        return decoder
    }
}

struct LossyDouble: Decodable {
    let value: Double?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self.value = nil
            return
        }

        if let doubleValue = try? container.decode(Double.self) {
            self.value = doubleValue
            return
        }
        if let intValue = try? container.decode(Int.self) {
            self.value = Double(intValue)
            return
        }
        if let stringValue = try? container.decode(String.self) {
            self.value = Double(stringValue)
            return
        }

        self.value = nil
    }
}
