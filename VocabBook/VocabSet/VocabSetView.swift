//
//  VocabSetView.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 24.09.23.
//  Copyright © 2023 Oliver Brehm. All rights reserved.
//

import SwiftUI
import SwiftData

struct VocabSetView: View {
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // MARK: - State
    @Bindable var vocabSet: VocabSet

    @State private var editingCard: VocabCard?
    @State private var learnViewType: VocabLearnView.CoverType?
    @State private var showConfirmDelete = false

    // MARK: - Private properties
    private var cards: [VocabCard] {
        vocabSet.cards ?? []
    }

    private var dueCards: [VocabCard] {
        cards.filter { $0.isDue }
    }

    private var cardsToLearn: [VocabCard] {
        dueCards.isEmpty ? cards : dueCards
    }

    private var showLearnView: Binding<Bool> {
        Binding(get: {
            learnViewType != nil
        }, set: {
            if !$0 {
                learnViewType = nil
            }
        })
    }

    // MARK: - Private functions
    private func cardsForLevel(_ level: CardLevel) -> [VocabCard] {
        cards.filter { $0.level == level }
    }
}

// MARK: - Actions
extension VocabSetView {
    private func addCard() {
        let card = VocabCard(front: "", back: "")
        modelContext.insert(card)
        vocabSet.cards?.append(card)
        editingCard = card
    }
}

// MARK: - UI
extension VocabSetView {
    var body: some View {
        List {
            NavigationLink {
                VocabSetEditView(vocabSet: vocabSet)
            } label: {
                Section {
                    VStack(alignment: .leading) {
                        Text(vocabSet.name)
                            .font(.title)
                        .bold()

                        Text("\(Strings.language.localized): \(vocabSet.language)")

                        if !vocabSet.descriptionText.isEmpty {
                            Text(vocabSet.descriptionText)
                        }
                    }
                }
            }

            Section {
                HStack {
                    Image(systemName: "plus.circle")
                        .foregroundStyle(.blue)
                    Button(Strings.addCard.localized, action: addCard)
                        .bold()
                }
            }

            if !cards.isEmpty {
                Section {
                    VStack(spacing: 24) {
                        HStack {
                            Image(systemName: "lightbulb")
                                .foregroundStyle(.orange)

                            Text(Strings.learnCards.localized)
                                .bold()

                            Spacer()

                            Text("\(dueCards.count) \(Strings.cardsDue.localized)")
                        }

                        HStack {
                            Spacer()
                            Button(Strings.coverFront.localized) { learnViewType = .front }
                                .buttonStyle(.borderedProminent)
                            Spacer()
                            Button(Strings.coverBack.localized) { learnViewType = .back }
                                .buttonStyle(.borderedProminent)
                            Spacer()
                        }
                        .bold()
                    }
                }
            }

            ForEach(CardLevel.allCases, id: \.self) { level in
                let cards = cardsForLevel(level)
                if !cards.isEmpty {
                    Section("\(Strings.level.localized) \(level.rawValue)") {
                        ForEach(cards, id: \.front) { card in
                            cardView(card)
                        }
                    }
                }
            }

            Section(Strings.delete.localized) {
                Button(Strings.delete.localized) {
                    showConfirmDelete = true
                }
                .foregroundStyle(.red)
            }
        }
        .navigationTitle(vocabSet.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    vocabSet.isFavorite.toggle()
                }, label: {
                    Image(systemName: vocabSet.isFavorite ? "star.fill" : "star")
                })
            }
        }
        .fullScreenCover(isPresented: showLearnView, content: {
            VocabLearnView(cards: cardsToLearn, coverType: learnViewType ?? .front)
        })
        .fullScreenCover(isPresented: Binding(get: {
            editingCard != nil
        }, set: {
            if !$0 {
                editingCard = nil
            }
        }), content: {
            if let editingCard {
                CardEditView(
                    translator: EmptyTranslator(), // TODO: translation suggestion feature not to be released yet
                    vocabCard: editingCard,
                    deleteAction: {
                        vocabSet.cards?.removeAll { $0.id == editingCard.id }
                        modelContext.delete(editingCard)
                    }
                )
            }
        })
        .alert(Strings.removeAllCardsQuestion.localized, isPresented: $showConfirmDelete) {
            Button(Strings.no.localized) {}

            Button(Strings.yes.localized.uppercased()) {
                modelContext.delete(vocabSet)
                dismiss()
            }
        }
    }

    private func cardView(_ card: VocabCard) -> some View {
        HStack(spacing: 12) {
            if card.isDue {
                Image(systemName: "lightbulb")
                    .foregroundStyle(.orange)
            }

            VStack(alignment: .leading) {
                Text(card.front.firstLine)
                    .bold()

                Text(card.back.firstLine)
            }

            Spacer()

            ImageButton(systemName: "rectangle.and.pencil.and.ellipsis") {
                editingCard = card
            }
            .foregroundStyle(.blue)
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Preview
struct VocabSetView_Previews: PreviewProvider {
    static var previews: some View {
        let previewContainer = PreviewContainer()

        if let set = previewContainer.vocabSet {
            VocabSetView(vocabSet: set)
                .modelContainer(previewContainer.modelContainer)

            NavigationStack {
                VocabSetView(vocabSet: set)
            }
            .modelContainer(previewContainer.modelContainer)
            .previewDisplayName("NavigationStack")
        }
    }
}
