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
private extension VocabSetView {
    func addCard() {
        let card = VocabCard(front: "", back: "")
        modelContext.insert(card)
        vocabSet.cards?.append(card)
        editingCard = card
        try? modelContext.save()
    }

    func deleteCard(_ card: VocabCard) {
        vocabSet.cards?.removeAll { $0.id == card.id }
        modelContext.delete(card)
        try? modelContext.save()
    }

    func deleteSet() {
        modelContext.delete(vocabSet)
        dismiss()
        try? modelContext.save()
    }
}

// MARK: - UI
extension VocabSetView {
    var body: some View {
        List {
            NavigationLink {
                VocabSetEditView(vocabSet: vocabSet)
                    .navigationTitle(Strings.editSet.localized)
            } label: {
                Section {
                    VStack(alignment: .leading) {
                        Text(vocabSet.name)
                            .font(.title)
                        .bold()

                        if !vocabSet.setLanguage.stringWithFlag.isEmpty {
                            Text(vocabSet.setLanguage.stringWithFlag)
                        }

                        if !vocabSet.descriptionText.isEmpty {
                            Spacer()
                                .frame(height: 1)
                                .frame(maxWidth: .infinity)
                                .background(.black)
                                .padding(.vertical, 4)
                            
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
                    LearnCardsView(
                        numberOfDueCards: dueCards.count,
                        coverFrontAction: { learnViewType = .front },
                        coverBackAction: { learnViewType = .back }
                    )
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
                    deleteAction: { deleteCard(editingCard) }
                )
            }
        })
        .alert(Strings.removeAllCardsQuestion.localized, isPresented: $showConfirmDelete) {
            Button(Strings.no.localized) {}
            Button(Strings.yes.localized.uppercased(), action: deleteSet)
        }
    }

    private func cardView(_ card: VocabCard) -> some View {
        HStack(spacing: 12) {
            if card.isDue {
                Image(systemName: "lightbulb")
                    .foregroundStyle(.orange)
            }

            VStack(alignment: .leading) {
                if !card.front.isEmpty {
                    Text(card.front.firstLine)
                        .bold()
                }

                if !card.back.isEmpty {
                    Text(card.back.firstLine)
                }
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
#Preview {
    let previewContainer = PreviewContainer()
    guard let set = previewContainer.vocabSet else { return EmptyView() }

    return VocabSetView(vocabSet: set)
        .modelContainer(previewContainer.modelContainer)
}

#Preview("NavigationStack") {
    let previewContainer = PreviewContainer()
    guard let set = previewContainer.vocabSet else { return EmptyView() }

    return NavigationStack {
        VocabSetView(vocabSet: set)
    }
    .modelContainer(previewContainer.modelContainer)
}
