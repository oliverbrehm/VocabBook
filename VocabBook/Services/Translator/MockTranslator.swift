//
//  MockTranslator.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 29.09.23.
//  Copyright © 2023 Oliver Brehm. All rights reserved.
//

import Foundation

final class MockTranslator: ITranslator {
    func queryTranslationSuggestions(for text: String) async -> [String] {
        text.split(separator: " ").map { String($0) }
    }
}
