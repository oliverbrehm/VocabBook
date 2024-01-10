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
    @Query(sort: [SortDescriptor(\VocabSet.name)])
    private var sets: [VocabSet]

    @Query(sort: [SortDescriptor(\VocabCard.creationDate), SortDescriptor(\VocabCard.front)]) private var cards: [VocabCard]

    @State private var showAddSetView = false
    @State private var editingCard: VocabCard?
    @AppStorage(UserDefaultsKeys.showAllSets.rawValue) private var showAllSets = false
    @AppStorage(UserDefaultsKeys.useAppBadgeCount.rawValue) var useAppBadgeCount = false

    // MARK: - Private functions
    private func updateAppBadge() {
        guard useAppBadgeCount else { return }
        let numberOfDueCards = sets.filter { $0.isFavorite }.reduce(0) { $0 + $1.dueCards.count }
        UNUserNotificationCenter.current().setBadgeCount(numberOfDueCards)
    }
}

// MARK: - UI
extension MainView {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 36) {
                    setList

                    if !cards.isEmpty {
                        cardList
                    }

                    if sets.isEmpty, cards.isEmpty {
                        HStack {
                            Text(Strings.noSetsInfo.localized)
                            Spacer()
                        }
                    }

                    Spacer()
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle(Strings.vocabBook.localized)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .sheet(isPresented: $showAddSetView, content: {
                VocabSetAddView()
            })
            .onAppear(perform: updateAppBadge)
            //.onChange(of: cards, updateAppBadge)
        }
    }

    private var setList: some View {
        VStack(alignment: .leading) {
            Text(Strings.sets.localized)
                .bold()

            ForEach(showAllSets ? sets : sets.filter { $0.isFavorite }) { set in
                NavigationLink {
                    VocabSetView(vocabSet: set)
                } label: {
                    setView(for: set)
                }
            }

            Button(showAllSets ? Strings.showFavorites.localized : Strings.showAll.localized) {
                showAllSets.toggle()
            }
            .padding()

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
    }

    private var cardList: some View {
        VStack(alignment: .leading) {
            Text(Strings.newesCards.localized)
                .bold()

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150, maximum: 180), spacing: 12)], alignment: .leading) {
                ForEach(cards.prefix(40)) { card in
                    Button {
                        editingCard = card
                    } label: {
                        cardView(for: card)
                    }
                    .buttonStyle(.plain)
                }
            }
            .fullScreenCover(isPresented: Binding(get: {
                editingCard != nil
            }, set: {
                if !$0 { editingCard = nil }
            }), content: {
                if let editingCard {
                    CardEditView(
                        translator: EmptyTranslator(), // TODO: translation suggestion feature not to be released yet
                        vocabCard: editingCard,
                        deleteAction: {
                            editingCard.vocabSet = nil
                            modelContext.delete(editingCard)
                        }
                    )
                }
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

                Text("\(set.dueCards.count)")
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
