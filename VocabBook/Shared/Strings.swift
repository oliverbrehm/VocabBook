//
//  Strings.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 20.10.23.
//  Copyright © 2023 Oliver Brehm. All rights reserved.
//

import Foundation

enum Strings: String {
    case vocabBook
    case noSetsInfo
    case sets
    case showFavorites
    case showAll
    case newesCards
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
        NSLocalizedString(rawValue, comment: "")
    }

    func localized(with parameters: String...) -> String {
        return String(format: localized, arguments: parameters)
    }
}
