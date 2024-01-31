//
//  VocabLearnView.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 25.09.23.
//  Copyright © 2023 Oliver Brehm. All rights reserved.
//

import SwiftUI

struct VocabLearnView {
    enum CoverType {
        case front, back
    }

    // MARK: - Environment
    @Environment(\.dismiss) var dismiss

    // MARK: - State
    @State private var remainingCards: [VocabCard] = []
    @State private var currentCard: VocabCard?
    @State private var nTotal = 0
    @State private var nRight = 0
    @State private var nWrong = 0
    @State private var isCovered = true
    @State private var animateRight = false
    @State private var animateWrong = false

    // MARK: - Properties
    let cards: [VocabCard]
    let coverType: CoverType
    var finishAction: (() -> Void)?

    // MARK: - Private properties
    private var nRemaining: Int {
        remainingCards.count + (currentCard != nil ? 1 : 0)
    }

    private var coverFront: Bool {
        coverType == .front && isCovered
    }

    private var coverBack: Bool {
        coverType == .back && isCovered
    }

    // MARK: - Private functions
    private func setup() {
        nTotal = cards.count
        remainingCards = cards
        nextCard()
    }

    private func finish() {
        finishAction?()
        dismiss()
    }
}

// MARK: - Actions
extension VocabLearnView {
    private func nextCard() {
        currentCard = remainingCards.isEmpty ? nil : remainingCards.removeFirst()
        isCovered = true
    }

    private func guessedRight() {
        animateRight.toggle()
        currentCard?.increaseLevel()
        nRight += 1
        nextCard()
    }

    private func guessedWrong() {
        animateWrong.toggle()
        currentCard?.resetLevel()
        nWrong += 1
        nextCard()
    }
}

// MARK: - UI
extension VocabLearnView: View {
    var body: some View {
        ZStack {
            VStack {
                stateView
                    .padding()

                Spacer()

                if currentCard == nil {
                    resultView
                    Spacer()
                } else if !isCovered {
                    Spacer()
                    actionView
                }
            }

            if let currentCard {
                cardView(card: currentCard)
            }
        }
        .onAppear(perform: setup)
        .ignoresSafeArea(edges: .bottom)
    }

    private var stateView: some View {
        HStack(spacing: Sizes.marginBigger) {
            HStack {
                Text("\(nRight)")
                Images.thumbsUp
                    .resizable()
                    .frame(width: Sizes.icon, height: Sizes.icon)
                    .foregroundStyle(.green)
                    .symbolEffect(.bounce, value: animateRight)
            }

            HStack {
                Text("\(nWrong)")
                Images.thumbsDown
                    .resizable()
                    .frame(width: Sizes.icon, height: Sizes.icon)
                    .foregroundStyle(.red)
                    .symbolEffect(.bounce, value: animateWrong)
            }

            Text("\(Strings.cardsLeft.localized): \(nRemaining)")

            Spacer()

            ImageButton(image: Images.closeFilled, size: Sizes.icon) {
                finish()
            }
        }
    }

    private func cardView(card: VocabCard) -> some View {
        VStack {
            coverableView(text: card.front, textCovered: coverFront, language: card.vocabSet?.setLanguage)

            Spacer()
                .frame(maxWidth: .infinity)
                .frame(height: Sizes.separator)
                .background(.gray)

            coverableView(text: card.back, textCovered: coverBack, language: card.vocabSet?.setLanguage)
        }
        .frame(maxWidth: .infinity)
        .background(Colors.cardBackground)
        .roundedCorners(Sizes.marginDefault)
        .padding()
    }

    @ViewBuilder
    private func coverableView(text: String, textCovered: Bool, language: SetLanguage?) -> some View {
        if textCovered {
            HStack(spacing: Sizes.marginBig) {
                if let flag = language?.emojiFlag {
                    Text(flag)
                        .font(.system(size: Sizes.iconBig))
                } else if let language = language?.languageString, !language.isEmpty {
                    Text("(\(language))")
                }

                ImageButton(image: Images.lightbulb2) {
                    isCovered = false
                }

                Spacer()
            }
            .padding()
        } else {
            HStack {
                Text(text)
                    .padding()
                Spacer()
            }
        }
    }

    @ViewBuilder
    private var actionView: some View {
        VStack(spacing: Sizes.marginDefault) {
            Text(Strings.knewTheAnswerQuestion.localized)

            HStack(spacing: Sizes.marginBig) {
                actionButton(text: Strings.no.localized, color: .red, roundedCorner: .topRight, action: guessedWrong)
                actionButton(text: Strings.yes.localized, color: .green, roundedCorner: .topLeft, action: guessedRight)
            }
        }
    }

    private func actionButton(text: String, color: Color, roundedCorner: UIRectCorner, action: @escaping () -> Void) -> some View {
        Button(action: action, label: {
            Text(text)
                .bold()
                .foregroundStyle(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .padding(.bottom, Sizes.marginBig)
                .background(color)
        })
        .roundedCorners(Sizes.marginDefault, corners: roundedCorner)
    }

    private var resultView: some View {
        VStack(spacing: Sizes.marginBig) {
            Text(Strings.learningComplete.localized)
                .bold()

            Text(Strings.learnResultInfo.localized(arguments: String(nRight), String(nTotal)))

            ImageButton(image: Images.checkmarkFilled) {
                finish()
            }
        }
        .padding(Sizes.marginBig)
        .background(Colors.cardBackground)
        .roundedCorners(Sizes.marginDefault)
    }
}

// MARK: - Preview
#Preview {
    let previewContainer = PreviewContainer()
    guard let set = previewContainer.vocabSet else { return EmptyView() }

    return VocabLearnView(cards: set.cards ?? [], coverType: .front)
        .modelContainer(previewContainer.modelContainer)
}
