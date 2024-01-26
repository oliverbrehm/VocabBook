//
//  Array+Extensions.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 26.01.24.
//  Copyright © 2024 Oliver Brehm. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {
    func removeDuplicates() -> Array {
        Array(Set(self))
    }
}
