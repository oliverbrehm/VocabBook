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
    @State private var nTotal = 0
    @State private var nRight = 0
    @State private var nWrong = 0
    @State private var isCovered = true
    @State private var animateRight = false
    @State private var animateWrong = false

    // MARK: - Private properties
    private var nRemaining: Int {
        remainingCards.count + (currentCard != nil ? 1 : 0)
    }

    // MARK: - Private functions
    private func setup() {
        nTotal = cards.count
        remainingCards = cards
        nextCard()
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
        .ignoresSafeArea(edges: .bottom)
    }

    private var stateView: some View {
        HStack(spacing: 32) {
            HStack {
                Text("\(nRight)")
                Image(systemName: "hand.thumbsup.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.green)
                    .symbolEffect(.bounce, value: animateRight)
            }

            HStack {
                Text("\(nWrong)")
                Image(systemName: "hand.thumbsdown.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.red)
                    .symbolEffect(.bounce, value: animateWrong)
            }

            Text("Cards left: \(nRemaining)")

            Spacer()

            ImageButton(systemName: "x.circle.fill", size: 28) {
                dismiss()
            }
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
                .frame(height: 1.5)
                .background(.gray.opacity(0.7))

            if isCovered {
                ImageButton(systemName: "lightbulb.2.fill") {
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
        VStack(spacing: 16) {
            Text("Knew the answer?")

            HStack(spacing: 20) {
                actionButton(text: "No", color: .red, roundedCorner: .topRight, action: guessedWrong)
                actionButton(text: "Yes", color: .green, roundedCorner: .topLeft, action: guessedRight)
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
                .padding(.bottom, 20)
                .background(color)
        })
        .cornerRadius(10, corners: roundedCorner)
    }

    private var resultView: some View {
        VStack(spacing: 20) {
            Text("Learning complete")
                .bold()

            Text("You knew \(nRight) of \(nTotal) words.")

            ImageButton(systemName: "checkmark.circle.fill") {
                dismiss()
            }
        }
        .padding(24)
        .background(.orange.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Preview
struct VocabLearnView_Previews: PreviewProvider {
    static var previews: some View {
        let previewContainer = PreviewContainer()
        VocabLearnView(cards: previewContainer.vocabSet.cards)
    }
}

// TODO: move
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct ImageButton: View {
    let systemName: String
    var size: CGFloat = 32
    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }, label: {
            Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        })
    }
}
