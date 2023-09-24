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
    @Query private var sets: [VocabSet]

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
                ForEach(sets, id: \.name) { set in
                    NavigationLink {
                        VocabSetView(vocabSet: set)
                    } label: {
                        Text(set.name)
                    }
                }
            }
            .navigationTitle("Vocab Book")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        VocabSetEditView()
                    } label: {
                        Text("Add")
                    }
                }
            }
        }

    }
}

// MARK: - Preview
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .modelContainer(for: [VocabSet.self, VocabCard.self], inMemory: true)
    }
}
