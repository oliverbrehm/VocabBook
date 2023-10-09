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
}

// MARK: - UI
extension MainView {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    VStack(alignment: .leading) {
                        Text("Sets")
                            .bold()

                        ForEach(sets, id: \.name) { set in
                            NavigationLink {
                                VocabSetView(vocabSet: set)
                            } label: {
                                setView(for: set)
                            }
                        }

                        Button(action: {
                            showAddSetView = true
                        }, label: {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24)
                        })
                        .padding([.top, .horizontal], 8)
                    }

                    if !cards.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Cards")
                                .bold()

                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150, maximum: 180), spacing: 12)], alignment: .leading) {
                                ForEach(cards) { card in
                                    cardView(for: card)
                                }
                            }
                        }
                    }

                    if sets.isEmpty, cards.isEmpty {
                        HStack {
                            Text("Nothing here yet. Create a new set first.\nIf you recently updated the app and your data is missing, try recovering it in the settings menu.")
                            Spacer()
                        }
                    }

                    Spacer()
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Vocab Book")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .fullScreenCover(isPresented: $showAddSetView, content: {
                VocabSetAddView()
            })
        }
    }

    private func setView(for set: VocabSet) -> some View {
        HStack {
            Image(systemName: set.isFavorite ? "star.fill" : "square.stack.3d.down.forward")
            Text(set.name)

            Spacer()

            if set.hasDueCards {
                Image(systemName: "lightbulb")
                    .foregroundStyle(.orange)
            }
        }
        .padding(12)
        .background(Color(uiColor: .tertiarySystemBackground))
        .background(.gray.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func cardView(for card: VocabCard) -> some View {
        VStack(alignment: .leading) {
            Text(card.front)
                .lineLimit(1)
                .bold()
                .padding(.horizontal)
                .padding(.vertical, 8)

            Spacer()
                .frame(height: 1)
                .frame(maxWidth: .infinity)
                .background(.gray)

            Text(card.back.firstLines(3, padding: true))
                .lineLimit(3)
                .padding(.horizontal)
                .padding(.vertical, 8)
        }
        .background(.orange.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - Preview
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .modelContainer(PreviewContainer().modelContainer)
    }
}
