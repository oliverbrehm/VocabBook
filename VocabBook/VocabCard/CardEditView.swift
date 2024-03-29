//
//  CardEditView.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 25.09.23.
//  Copyright © 2023 Oliver Brehm. All rights reserved.
//

import SwiftUI
import SwiftData

struct CardEditView {
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
    @State private var showConfirmDelete = false
    @State private var showConfirmReset = false
    @State private var lookupWord: String?
    @FocusState private var focussedView: Tab?

    // MARK: - Properties
    @Bindable var vocabCard: VocabCard
    let translator: any ITranslator
    let deleteAction: () -> Void
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
extension CardEditView: View {
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
                Button(action: {
                    withAnimation {
                        selectedTab = (selectedTab == Tab.front ? .back : .front)
                    }
                }, label: {
                    HStack {
                        Images.rotateRight
                        Text(selectedTab == .front ? Strings.back.localized : Strings.front.localized)
                    }
                })

                Spacer()

                Button(action: close, label: {
                    Images.triangleDown
                })

                Spacer()

                Button(action: {
                    withAnimation {
                        selectedTab = .settings
                    }
                }, label: {
                    HStack {
                        Images.settings
                        Text(Strings.settings.localized)
                    }
                })
                .disabled(selectedTab == .settings)
            }
            .padding([.leading, .trailing, .bottom], Sizes.marginBigger)
        }
        .background(Colors.containerBackground)
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
                HStack(spacing: Sizes.marginDefault) {
                    Button(action: {
                        addTranslation(translation)
                    }, label: {
                        Images.plus
                    })
                    .tint(.green)

                    Text(translation)

                    Spacer()

                    Button(action: {
                        removeTranslationSuggestion(translation)
                    }, label: {
                        Images.close
                    })
                    .tint(.red)
                }
                .padding(Sizes.marginDefault)
                .background(Colors.elementBackground)
                .roundedCorners(Sizes.marginDefault)
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
        .padding(Sizes.marginDefault)
        .background(Colors.cardBackground)
        .roundedCorners(Sizes.marginDefault)
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
                Button(action: {
                    showConfirmReset = true
                }, label: {
                    HStack {
                        Images.rotateLeft
                        Text(Strings.resetLevel.localized)
                    }
                })
                .alert(Strings.confirmResetSetQuestion.localized, isPresented: $showConfirmReset) {
                    Button(Strings.no.localized) {}

                    Button(Strings.yes.localized) {
                        vocabCard.level = .level0
                    }
                }

                Button(action: {
                    showConfirmDelete = true
                }, label: {
                    HStack {
                        Images.delete
                        Text(Strings.deleteCard.localized)
                    }
                })
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
        vocabCard: previewContainer.newCard(), 
        translator: MockTranslator(),
        deleteAction: {}
    )
    .modelContainer(previewContainer.modelContainer)
}
