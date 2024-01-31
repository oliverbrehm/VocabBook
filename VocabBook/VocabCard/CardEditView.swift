//
//  CardEditView.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 25.09.23.
//  Copyright © 2023 Oliver Brehm. All rights reserved.
//

import SwiftUI
import SwiftData

struct CardEditView: View {
    private enum Tab {
        case front, back, settings
    }

    // MARK: - Environment
    @Environment(\.dismiss) var dismiss

    @Query(sort: [SortDescriptor(\VocabSet.name)])
    private var sets: [VocabSet]

    // MARK: - State
    @State private var selectedTab = Tab.front
    @State private var translationSuggestions: [String] = []
    @FocusState private var focussedView: Tab?

    @State var showConfirmDelete = false
    @State var showConfirmReset = false
    // MARK: - Properties
    let translator: any ITranslator
    @Bindable var vocabCard: VocabCard
    let deleteAction: () -> Void

    // MARK: - Private properties
    @State private var lookupWord: String?
}

// MARK: - Actions
extension CardEditView {
    private func backAppeared() {
        if vocabCard.back.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            focussedView = .back
        }

        Task {
            translationSuggestions = await translator.queryTranslationSuggestions(for: vocabCard.front)
        }
    }

    private func addTranslation(_ translation: String) {
        guard !translation.isEmpty else { return }

        if vocabCard.back.last != Character("\n") {
            vocabCard.back += "\n"
        }

        vocabCard.back += "\(translation)\n"

        removeTranslationSuggestion(translation)
    }

    private func removeTranslationSuggestion(_ translation: String) {
        translationSuggestions.removeAll { $0 == translation }
    }

    private func close() {
        if vocabCard.front.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && vocabCard.back.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            deleteCard()
        } else {
            vocabCard.trim()
            dismiss()
        }
    }

    private func deleteCard() {
        deleteAction()
        dismiss()
    }
}

// MARK: - UI
extension CardEditView {
    var body: some View {
        VStack {
            TabView(selection: $selectedTab) {
                textInputView(title: Strings.front.localized, text: $vocabCard.front, focus: .front)
                    .tag(Tab.front)
                    .onTapGesture {
                        focussedView = .front
                    }

                backView
                    .tag(Tab.back)
                    .onTapGesture {
                        focussedView = .back
                    }
                    .onAppear(perform: backAppeared)

                settingsView
                    .tag(Tab.settings)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .padding([.top, .bottom])

            HStack {
                Button(selectedTab == .front ? Strings.back.localized : Strings.front.localized, systemImage: "arrow.clockwise.circle.fill") {
                    withAnimation {
                        selectedTab = (selectedTab == Tab.front ? .back : .front)
                    }
                }

                Spacer()

                Button(action: close, label: {
                    Image(systemName: "arrowtriangle.down.circle.fill")
                })

                Spacer()

                Button(Strings.settings.localized, systemImage: "gear") {
                    withAnimation {
                        selectedTab = .settings
                    }
                }
                .disabled(selectedTab == .settings)
            }
            .padding([.leading, .trailing, .bottom], 32)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .onAppear {
            if vocabCard.front.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                focussedView = .front
            }
        }
    }

    private var backView: some View {
        VStack {
            textInputView(title: Strings.back.localized, text: $vocabCard.back, focus: .back)

            ForEach(translationSuggestions, id: \.self) { translation in
                HStack(spacing: 16) {
                    Button(action: {
                        addTranslation(translation)
                    }, label: {
                        Image(systemName: "plus.circle")
                    })
                    .tint(.green)

                    Text(translation)

                    Spacer()

                    Button(action: {
                        removeTranslationSuggestion(translation)
                    }, label: {
                        Image(systemName: "x.circle")
                    })
                    .tint(.red)
                }
                .padding(8)
                .background(.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal)
            }
        }
    }

    private func textInputView(title: String, text: Binding<String>, focus: Tab) -> some View {
        VStack {
            TextField(title, text: text, axis: .vertical)
                .focused($focussedView, equals: focus)

            Spacer()
        }
        .padding(20)
        .background(.orange.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding([.leading, .trailing])
    }

    private var settingsView: some View {
        Form {
            if let setName = vocabCard.vocabSet?.name {
                Section(Strings.set.localized) {
                    Menu(setName) {
                        ForEach(sets) { set in
                            Button(set.name) {
                                vocabCard.vocabSet = set
                            }
                        }
                    }
                }
            }

            Section(Strings.reset.localized) {
                Button(Strings.resetLevel.localized, systemImage: "arrow.uturn.backward.circle") {
                    showConfirmReset = true
                }
                .alert(Strings.confirmResetSetQuestion.localized, isPresented: $showConfirmReset) {
                    Button(Strings.no.localized) {}

                    Button(Strings.yes.localized) {
                        vocabCard.level = .level0
                    }
                }

                Button(Strings.deleteCard.localized, systemImage: "trash.fill") {
                    showConfirmDelete = true
                }
                .foregroundStyle(.red)
                .alert(Strings.confirmRemoveCardQuestion.localized, isPresented: $showConfirmDelete) {
                    Button(Strings.no.localized) {}

                    Button(Strings.yes.localized.uppercased()) {
                        deleteCard()
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
    }
}

// MARK: - Preview
#Preview {
    let previewContainer = PreviewContainer()

    return CardEditView(
        translator: MockTranslator(),
        vocabCard: previewContainer.newCard(),
        deleteAction: {}
    )
    .modelContainer(previewContainer.modelContainer)
}
