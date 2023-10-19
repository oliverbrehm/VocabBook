//
//  EmptyTranslator.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 19.10.23.
//  Copyright © 2023 Oliver Brehm. All rights reserved.
//

import Foundation

final class EmptyTranslator: ITranslator {
    func queryTranslationSuggestions(for text: String) async -> [String] {
        []
    }
}
