//
//  Strings.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 20.10.23.
//  Copyright © 2023 Oliver Brehm. All rights reserved.
//

import SwiftUI

enum Strings: String {
    case vocabBook
    case noSetsInfo
    case sets
    case showFavorites
    case showAll
    case cards
    case recoverICloud
    case recoverICloudInfo
    case useAppBadge
    case useAppBadgeInfo
    case settings
    case removeAllCardsQuestion
    case yes
    case no
    case addVocabSet
    case name
    case description
    case add
    case cancel
    case editSet
    case cardsLeft
    case knewTheAnswerQuestion
    case learningComplete
    case learnResultInfo
    case front
    case back
    case delete
    case level
    case coverBack
    case coverFront
    case cardsDue
    case learnCards
    case addCard
    case language
    case set
    case reset
    case resetLevel
    case confirmResetSetQuestion
    case deleteCard
    case confirmRemoveCardQuestion
}

extension Strings {
    var localized: String {
        String.localized(self)
    }

    func localized(arguments: String...) -> String {
        String(format: NSLocalizedString(self.rawValue, comment: ""), arguments: arguments)
    }
}

extension String {
    init(_ key: Strings) {
        self = Self.localized(key)
    }

    static func localized(_ key: Strings) -> String {
        NSLocalizedString(key.rawValue, comment: "")
    }
}

extension Text {
    init(_ localizationKey: Strings) {
        self = .init(verbatim: .localized(localizationKey))
    }
}
