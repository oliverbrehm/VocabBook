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
}

extension Locale.LanguageCode {
    var languageString: String {
        Locale.current.localizedString(forLanguageCode: identifier) ?? ""
    }

    var regions: [Locale.Region] {
        let locales = Locale.availableIdentifiers.map { Locale(identifier: $0) }
        let languageRegions = locales.filter { $0.language.languageCode?.identifier == identifier }.compactMap { $0.region?.identifier }.removeDuplicates().sorted()
        let otherRegions = locales.compactMap { $0.region?.identifier }.filter { !languageRegions.contains($0) }.removeDuplicates().sorted()

        return (languageRegions + otherRegions).compactMap { Locale.Region($0) }.filter { $0.identifier.rangeOfCharacter(from: .decimalDigits) == nil }
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
