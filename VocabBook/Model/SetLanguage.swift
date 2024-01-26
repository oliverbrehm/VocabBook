//
//  SetLanguage.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 26.01.24.
//  Copyright © 2024 Oliver Brehm. All rights reserved.
//

import Foundation

struct SetLanguage {
    // MARK: - Properties
    let languageIdentifier: String
    let regionIdentifier: String

    var language: Locale.LanguageCode {
        Locale.LanguageCode(languageIdentifier)
    }

    var region: Locale.Region {
        Locale.Region(regionIdentifier)
    }

    var stringWithFlag: String {
        if let emojiFlag {
            return "\(emojiFlag) \(languageString)"
        } else {
            return languageString
        }
    }

    var languageString: String {
        !language.languageString.isEmpty ? language.languageString : languageIdentifier
    }

    var emojiFlag: String? {
        region.emojiFlag
    }

    // MARK: - Static properties
    static func allLanguages() -> [Locale.LanguageCode] {
        Locale.LanguageCode.isoLanguageCodes
            .filter { !$0.languageString.isEmpty }
            .sorted { $0.languageString < $1.languageString }
    }

    static func regionsForLanguage(_ language: Locale.LanguageCode) -> [Locale.Region] {
        let locales = Locale.availableIdentifiers
            .map { Locale(identifier: $0) }

        let languageLocales = locales.filter { $0.language.languageCode == language }.removeDuplicates().sorted { $0.identifier < $1.identifier }
        let otherLocales = locales.filter { $0.language.languageCode != language }.removeDuplicates().sorted { $0.identifier < $1.identifier }

        return (languageLocales + otherLocales)
            .compactMap { $0.region }
    }
}

extension Locale.LanguageCode {
    var languageString: String {
        Locale.current.localizedString(forLanguageCode: identifier) ?? ""
    }
}

extension Locale.Region {
    var emojiFlag: String? {
        let code = identifier.uppercased()
        guard code.count == 2 else { return nil }

        let symbols = code.lowercased().unicodeScalars
            .compactMap { Unicode.Scalar($0.value + (0x1F1E6 - 0x61)) }
            .compactMap { Character($0) }

        return String(symbols)
    }
}
