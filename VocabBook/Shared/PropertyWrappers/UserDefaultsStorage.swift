//
//  UserDefaultsStorage.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 20.10.23.
//  Copyright © 2023 Oliver Brehm. All rights reserved.
//

import Foundation

@propertyWrapper struct UserDefaultsStorage<T: Codable> {
    private let key: UserDefaultsKeys
    private let defaultValue: T

    var wrappedValue: T {
        get {
            if let value = UserDefaults.standard.value(forKey: key.rawValue) as? T {
                return value
            } else {
                return defaultValue
            }
        }

        set {
            UserDefaults.standard.setValue(newValue, forKey: key.rawValue)
            UserDefaults.standard.synchronize()
        }
    }

    init(wrappedValue: T, _ key: UserDefaultsKeys) {
        self.defaultValue = wrappedValue
        self.key = key
    }
}
