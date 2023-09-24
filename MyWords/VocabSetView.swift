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

    // MARK: - Properties
    let vocabSet: VocabSet

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
            Button("Add") {
                let card = VocabCard(front: "Test \(Int.random(in: 0 ..< 100))", back: "Back")
                modelContext.insert(card)
                vocabSet.cards.append(card)
            }

            ForEach(vocabSet.cards, id: \.front) { card in
                VStack {
                    Text(card.front).bold()
                    Text(card.back)
                }
            }
        }
    }
}

// MARK: - Preview
struct VocabSetView_Previews: PreviewProvider {
    static var previews: some View {
        let container = try! ModelContainer(for: VocabSet.self)

        let vocabSet = VocabSet(name: "test")
        container.mainContext.insert(vocabSet)

        return VocabSetView(vocabSet: vocabSet)
            .modelContainer(container)
    }
}
