//
//  CodableAppStorage.swift
//  Valetudo
//
//  Created by David Klopp on 05.08.25.
//

import Foundation

/// Persists the last robot the user selected so startup can restore it when possible.
struct VTSelectedRobot: Codable {
    let id: String
    let lastURL: URL
}

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

/// Stores app-scoped preferences that need to be shared across multiple controllers.
final class VTAppSettingsStore: @unchecked Sendable {
    /// Shared singleton used by the app to access persisted settings.
    static let shared = VTAppSettingsStore()

    @CodableAppStorage("appSettings.hideNoGoAreas")
    private var storedHideNoGoAreas = false
    
    @CodableAppStorage("selectedRobot")
    private var storedSelectedRobot: VTSelectedRobot? = nil

    /// Whether the home map should hide no-go areas from the rendered map.
    var hideNoGoAreas: Bool {
        get { storedHideNoGoAreas }
        set { storedHideNoGoAreas = newValue }
    }

    /// The last robot selected by the user, used to restore the app state on launch.
    var selectedRobot: VTSelectedRobot? {
        get { storedSelectedRobot }
        set { storedSelectedRobot = newValue }
    }

    /// Prevents external initialization so all callers share the same persisted store.
    private init() {}
}
