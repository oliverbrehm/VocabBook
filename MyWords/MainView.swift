//
//  MainView.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 24.09.23.
//  Copyright © 2023 Oliver Brehm. All rights reserved.
//

import SwiftData
import SwiftUI

struct MainView: View {
    // MARK: - Environment
    @Environment(\.modelContext) private var modelContext

    // MARK: - State
    @Query(sort: [SortDescriptor(\VocabSet.name)]) private var sets: [VocabSet]
    @Query(sort: [SortDescriptor(\VocabCard.front)]) private var cards: [VocabCard]
    @State private var showAddSetView = false

    // MARK: - Properties

    // MARK: - Functions

    // MARK: - Private properties

    // MARK: - Private functions
}

// MARK: - Actions
extension MainView {

}

// MARK: - UI
extension MainView {
    var body: some View {
        NavigationStack {
            List {
                if !sets.isEmpty {
                    Section("Sets") {
                        ForEach(sets, id: \.name) { set in
                            NavigationLink {
                                VocabSetView(vocabSet: set)
                            } label: {
                                Text(set.name)
                            }
                        }
                    }
                }

                if !cards.isEmpty {
                    Section("Cards") {
                        ForEach(cards) { card in
                            VStack(alignment: .leading) {
                                Text(card.front).bold()
                                Text(card.back)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Vocab Book")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        showAddSetView = true
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showAddSetView, content: {
            VocabSetAddView()
        })
    }
}

// MARK: - Preview
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .modelContainer(PreviewContainer().modelContainer)
    }
}

@MainActor
struct PreviewContainer {
    let modelContainer: ModelContainer

    let vocabSet: VocabSet
    let vocabCard: VocabCard

    init() {
        guard let container = try? ModelContainer(
            for: VocabSet.self, VocabCard.self,
            configurations: .init(isStoredInMemoryOnly: true)
        ) else {
            fatalError("Error creating preview model container.")
        }

        modelContainer = container
        vocabSet = VocabSet(
            name: "German",
            descriptionText: "This is a test set for view previews. It contains a few german words to simulate learning."
        )
        container.mainContext.insert(vocabSet)

        vocabCard = VocabCard(front: "Potato", back: "Kartoffel")

        let cards = [
            vocabCard,
            VocabCard(front: "Chair", back: "Stuhl"),
            VocabCard(front: "to work", back: "arbeiten"),
            VocabCard(front: "to cook", back: "kochen"),
            VocabCard(front: "vacation", back: "Urlaub\nFerien")
        ]

        for card in cards {
            vocabSet.cards.append(card)
            container.mainContext.insert(card)
        }
    }
}
