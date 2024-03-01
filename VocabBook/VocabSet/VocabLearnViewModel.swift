//
//  VocabLearnViewModel.swift
//  Vocab BookTests
//
//  Created by Oliver Brehm on 01.03.24.
//  Copyright © 2024 Oliver Brehm. All rights reserved.
//

import Foundation

final class VocabLearnViewModel: ObservableObject {
    enum CoverType {
        case front, back
    }

    // MARK: - Properties
    @Published var remainingCards: [VocabCard] = []
    @Published var currentCard: VocabCard?
    @Published var nTotal = 0
    @Published var nRight = 0
    @Published var nWrong = 0
    @Published var isCovered = true
    @Published var animateRight = false
    @Published var animateWrong = false

    let coverType: CoverType

    var nRemaining: Int {
        remainingCards.count + (currentCard != nil ? 1 : 0)
    }

    var coverFront: Bool {
        coverType == .front && isCovered
    }

    var coverBack: Bool {
        coverType == .back && isCovered
    }

    // MARK: - Initializers
    init(cards: [VocabCard], coverType: CoverType) {
        self.coverType = coverType

        nTotal = cards.count
        remainingCards = cards
        nextCard()
    }

    // MARK: - Functions
    func uncover() {
        isCovered = false
    }

    func nextCard() {
        currentCard = remainingCards.isEmpty ? nil : remainingCards.removeFirst()
        isCovered = true
    }

    func guessedRight() {
        animateRight.toggle()
        currentCard?.increaseLevel()
        nRight += 1
        nextCard()
    }

    func guessedWrong() {
        animateWrong.toggle()
        currentCard?.resetLevel()
        nWrong += 1
        nextCard()
    }
}
