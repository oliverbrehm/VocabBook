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
    @State var editingCard: VocabCard?
    @Bindable var vocabSet: VocabSet
    @State var showLearnView = false
    @State var showConfirmDelete = false

    // MARK: - Private properties
    private var dueCards: [VocabCard] {
        vocabSet.cards.filter { $0.isDue }
    }

    private var cardsToLearn: [VocabCard] {
        dueCards.isEmpty ? vocabSet.cards : dueCards
    }

    // MARK: - Private functions
    private func cardsForLevel(_ level: CardLevel) -> [VocabCard] {
        vocabSet.cards
            .filter { $0.level == level }
    }
}

// MARK: - Actions
extension VocabSetView {
    private func addCard() {
        let card = VocabCard(front: "", back: "")
        modelContext.insert(card)
        vocabSet.cards.append(card)
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

                        Text("Language: \(vocabSet.language)")

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
                    Button("Add card", action: addCard)
                        .bold()
                }
            }

            if !vocabSet.cards.isEmpty {
                Section {
                    HStack {
                        Image(systemName: "lightbulb")
                            .foregroundStyle(.blue)

                        VStack(alignment: .leading) {
                            Button("Learn cards") {
                                showLearnView = true
                            }
                            .bold()

                            Text("\(dueCards.count) cards due")
                                .font(.footnote)
                        }
                    }
                }
            }

            ForEach(CardLevel.allCases, id: \.self) { level in
                let cards = cardsForLevel(level)
                if !cards.isEmpty {
                    Section("Level \(level.rawValue)") {
                        ForEach(cards, id: \.front) { card in
                            cardView(card)
                        }
                    }
                }
            }

            Section("Delete") {
                Button("Delete") {
                    showConfirmDelete = true
                }
                .foregroundStyle(.red)
            }
        }
        .navigationTitle(vocabSet.name)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showLearnView, content: {
            VocabLearnView(cards: cardsToLearn)
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
                    translator: LibreTranslator(),
                    vocabCard: editingCard,
                    deleteAction: {
                        vocabSet.cards.removeAll { $0.id == editingCard.id }
                        modelContext.delete(editingCard)
                    }
                )
            }
        })
        .alert("Do you really want to remove the set and all cards?", isPresented: $showConfirmDelete) {
            Button("No") {}

            Button("YES") {
                modelContext.delete(vocabSet)
                dismiss()
            }
        }
    }

    private func cardView(_ card: VocabCard) -> some View {
        HStack(spacing: 12) {
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

            if card.isDue {
                Image(systemName: "lightbulb")
                    .foregroundStyle(.orange)
            }
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
