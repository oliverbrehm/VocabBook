//
//  VocabLearnView.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 25.09.23.
//  Copyright © 2023 Oliver Brehm. All rights reserved.
//

import SwiftUI

struct VocabLearnView {
    // MARK: - Environment
    @Environment(\.dismiss) var dismiss

    // MARK: - Properties
    @ObservedObject var viewModel: VocabLearnViewModel
    var finishAction: (() -> Void)?

    // MARK: - Private functions
    private func finish() {
        finishAction?()
        dismiss()
    }
}

// TODO: bug nRight and nWrong not updated, nothing happens when finished
// MARK: - UI
extension VocabLearnView: View {
    var body: some View {
        ZStack {
            VStack {
                stateView
                    .padding()

                Spacer()

                if viewModel.currentCard == nil {
                    resultView
                    Spacer()
                } else if !viewModel.isCovered {
                    Spacer()
                    actionView
                }
            }

            if let currentCard = viewModel.currentCard {
                cardView(card: currentCard)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private var stateView: some View {
        HStack(spacing: Sizes.marginBigger) {
            HStack {
                Text("\(viewModel.nRight)")
                Images.thumbsUp
                    .resizable()
                    .frame(width: Sizes.icon, height: Sizes.icon)
                    .foregroundStyle(.green)
                    .symbolEffect(.bounce, value: viewModel.animateRight)
            }

            HStack {
                Text("\(viewModel.nWrong)")
                Images.thumbsDown
                    .resizable()
                    .frame(width: Sizes.icon, height: Sizes.icon)
                    .foregroundStyle(.red)
                    .symbolEffect(.bounce, value: viewModel.animateWrong)
            }

            Text("\(Strings.cardsLeft.localized): \(viewModel.nRemaining)")

            Spacer()

            ImageButton(image: Images.closeFilled, size: Sizes.icon) {
                finish()
            }
        }
    }

    private func cardView(card: VocabCard) -> some View {
        VStack {
            coverableView(text: card.front, textCovered: viewModel.coverFront, language: card.vocabSet?.setLanguage)

            Spacer()
                .frame(maxWidth: .infinity)
                .frame(height: Sizes.separator)
                .background(.gray)

            coverableView(text: card.back, textCovered: viewModel.coverBack, language: card.vocabSet?.setLanguage)
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
                    viewModel.uncover()
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
                actionButton(text: Strings.no.localized, color: .red, roundedCorner: .topRight, action: viewModel.guessedWrong)
                actionButton(text: Strings.yes.localized, color: .green, roundedCorner: .topLeft, action: viewModel.guessedRight)
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

            Text(Strings.learnResultInfo.localized(arguments: String(viewModel.nRight), String(viewModel.nTotal)))

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

    return VocabLearnView(viewModel: VocabLearnViewModel(cards: set.cards ?? [], coverType: .front), finishAction: nil)
        .modelContainer(previewContainer.modelContainer)
}
