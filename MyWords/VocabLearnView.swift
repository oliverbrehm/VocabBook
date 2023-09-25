//
//  VocabLearnView.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 25.09.23.
//  Copyright © 2023 Oliver Brehm. All rights reserved.
//

import SwiftUI

struct VocabLearnView: View {
    // MARK: - Environment
    @Environment(\.dismiss) var dismiss

    // MARK: - State
    var cards: [VocabCard]

    // MARK: - Properties
    @State private var remainingCards: [VocabCard] = []
    @State private var currentCard: VocabCard? = nil
    @State private var nRight = 0
    @State private var nWrong = 0
    @State private var isCovered = true

    // MARK: - Functions

    // MARK: - Private properties
    private var nRemaining: Int {
        remainingCards.count + (currentCard != nil ? 1 : 0)
    }

    // MARK: - Private functions
    private func setup() {
        remainingCards = cards
        nextCard()
    }

    private func nextCard() {
        currentCard = remainingCards.isEmpty ? nil : remainingCards.removeFirst()
        isCovered = true
    }

    private func guessedRight() {
        currentCard?.increaseLevel()
        nRight += 1
        nextCard()
    }

    private func guessedWrong() {
        currentCard?.resetLevel()
        nWrong += 1
        nextCard()
    }
}

// MARK: - Actions
extension VocabLearnView {

}

// MARK: - UI
extension VocabLearnView {
    var body: some View {
        VStack {
            stateView
                .padding()

            Spacer()

            if let currentCard {
                cardView(card: currentCard)

                Spacer()

                if !isCovered {
                    actionView
                }
            } else {
                resultView
                Spacer()
            }
        }
        .onAppear(perform: setup)
    }

    private var stateView: some View {
        HStack {
            Text("Right: \(nRight)")
            Text("Wrong: \(nWrong)")

            Spacer()

            Text("Cards left: \(nRemaining)")
        }
    }

    private func cardView(card: VocabCard) -> some View {
        VStack {
            HStack {
                Text(card.front)
                    .padding()
                Spacer()
            }

            Spacer()
                .frame(maxWidth: .infinity)
                .frame(height: 2)
                .background(.black)

            if isCovered {
                Button("Reveal") {
                    isCovered = false
                }
                .padding()
            } else {
                HStack {
                    Text(card.back)
                        .padding()
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(.orange.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding()
    }

    @ViewBuilder
    private var actionView: some View {
        HStack(spacing: 0) {
            actionButton(text: "Wrong", color: .red, action: guessedWrong)
            actionButton(text: "Right", color: .green, action: guessedRight)
        }
    }

    private func actionButton(text: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action, label: {
            Text(text)
                .foregroundStyle(.white)
                .bold()
                .padding()
                .frame(maxWidth: .infinity)
                .background(color)
        })
    }

    private var resultView: some View {
        VStack(spacing: 20) {
            Text("Learning complete")
                .bold()

            Text("You knew \(nRight) of \(cards.count) words.")
            Button("Finish") {
                dismiss()
            }
        }
    }
}

// MARK: - Preview
struct VocabLearnView_Previews: PreviewProvider {
    static var previews: some View {
        let previewContainer = PreviewContainer()
        VocabLearnView(cards: previewContainer.vocabSet.cards)
    }
}
