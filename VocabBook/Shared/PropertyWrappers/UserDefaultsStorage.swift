//
//  UserDefaultsStorage.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 20.10.23.
//  Copyright © 2023 Oliver Brehm. All rights reserved.
//

import Foundation

@propertyWrapper struct UserDefaultsStorage<T: Codable> {
    private let key: String
    private let defaultValue: T

    var wrappedValue: T {
        get {
            UserDefaults.standard.value(forKey: key) as? T ?? defaultValue
        }

        set {
            UserDefaults.standard.setValue(newValue, forKey: key)
            UserDefaults.standard.synchronize()
        }
    }

    init(wrappedValue: T, _ key: String) {
        self.defaultValue = wrappedValue
        self.key = key

        self.wrappedValue = wrappedValue
    }
}
