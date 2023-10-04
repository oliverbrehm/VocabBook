//
//  LibreTranslator.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 29.09.23.
//  Copyright © 2023 Oliver Brehm. All rights reserved.
//

import Foundation
import LibreTranslate

final class LibreTranslator: ITranslator {
    private let translator = Translator("https://libretranslate.de")

    private var lookupText: String?

    func queryTranslationSuggestions(for text: String) async -> [String] {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard text != lookupText else { return [] }

        lookupText = text

        guard let translation = try? await translator.translate(text, from: "en", to: "de") else { return [] }

        return [translation]
    }
}
