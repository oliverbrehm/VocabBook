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

    // MARK: - Properties

    // MARK: - Functions

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

                        if !vocabSet.descriptionText.isEmpty {
                            Text(vocabSet.descriptionText)
                        }
                    }
                }
            }

            Section {
                Button("Add card") {
                    let card = VocabCard(front: "Test \(Int.random(in: 0 ..< 100))", back: "Back")
                    modelContext.insert(card)
                    vocabSet.cards.append(card)
                }
            }

            Section {
                VStack(alignment: .leading) {
                    Button("Learn cards") {
                        showLearnView = true
                    }

                    Text("\(dueCards.count) cards due")
                        .font(.footnote)
                }
            }

            ForEach(CardLevel.allCases, id: \.self) { level in
                let cards = cardsForLevel(level)
                if !cards.isEmpty {
                    Section("Level \(level.rawValue)") {
                        ForEach(cards, id: \.front) { card in
                            Button(action: {
                                editingCard = card
                            }, label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(card.front).bold()
                                        Text(card.back)
                                    }

                                    Spacer()

                                    if card.isDue {
                                        Text("DUE")
                                            .font(.system(size: 10))
                                            .bold()
                                            .foregroundStyle(.white)
                                            .padding(4)
                                            .background(.orange)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                            })
                            .buttonStyle(.plain)
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
                CardEditView(vocabCard: editingCard, deleteAction: {
                    vocabSet.cards.removeAll { $0.id == editingCard.id }
                    modelContext.delete(editingCard)
                })
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
}

// MARK: - Preview
struct VocabSetView_Previews: PreviewProvider {
    static var previews: some View {
        let previewContainer = PreviewContainer()

        VocabSetView(vocabSet: previewContainer.vocabSet)
            .modelContainer(previewContainer.modelContainer)

        NavigationStack {
            VocabSetView(vocabSet: previewContainer.vocabSet)
        }
        .modelContainer(previewContainer.modelContainer)
    }
}
