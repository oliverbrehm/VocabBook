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
    @Environment(\.modelContext) private var modelContext

    // MARK: - State
    @State var editingCard: VocabCard?
    @Bindable var vocabSet: VocabSet
    @State var showLearnView = false

    // MARK: - Properties

    // MARK: - Functions

    // MARK: - Private properties

    // MARK: - Private functions
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
                Button("Learn cards") {
                    showLearnView = true
                }
            }

            Section("Cards") {
                ForEach($vocabSet.cards, id: \.front, editActions: .delete) { $card in
                    Button(action: {
                        editingCard = card
                    }, label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(card.front).bold()
                                Text(card.back)
                            }

                            Spacer()

                            Text("Level \(card.level.rawValue)")
                        }
                    })
                    .buttonStyle(.plain)
                }
            }
        }
        .fullScreenCover(isPresented: $showLearnView, content: {
            VocabLearnView(cards: vocabSet.cards)
        })
        .sheet(isPresented: Binding(get: {
            editingCard != nil
        }, set: {
            if !$0 {
                editingCard = nil
            }
        }), content: {
            if let editingCard {
                CardEditView(vocabCard: editingCard)
            }
        })
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
