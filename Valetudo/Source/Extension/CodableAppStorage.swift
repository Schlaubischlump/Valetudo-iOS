//
//  CodableAppStorage.swift
//  Valetudo
//
//  Created by Codex on 05.08.25.
//

import Foundation

@propertyWrapper
struct CodableAppStorage<Value: Codable> {
    private let key: String
    private let store: UserDefaults
    private let defaultValue: Value
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(wrappedValue defaultValue: Value, _ key: String, store: UserDefaults = .standard) {
        self.key = key
        self.store = store
        self.defaultValue = defaultValue
    }

    var wrappedValue: Value {
        get {
            guard let data = store.data(forKey: key) else { return defaultValue }
            return (try? decoder.decode(Value.self, from: data)) ?? defaultValue
        }
        set {
            guard let data = try? encoder.encode(newValue) else {
                store.removeObject(forKey: key)
                return
            }

            store.set(data, forKey: key)
        }
    }
}
