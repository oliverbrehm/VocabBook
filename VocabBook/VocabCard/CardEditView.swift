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
    private enum Focus {
        case front, back
    }

    // MARK: - Environment
    @Environment(\.dismiss) var dismiss

    // MARK: - State
    @State private var selectedTab = "Front"
    @State private var translationSuggestions: [String] = []
    @FocusState private var focussedView: Focus?

    @State var showConfirmDelete = false
    // MARK: - Properties
    let translator: any ITranslator
    @Bindable var vocabCard: VocabCard
    let deleteAction: () -> Void

    // MARK: - Private properties
    @State private var lookupWord: String?

    // MARK: - Private functions
    private func trimCard() {
        vocabCard.front = vocabCard.front.trimmingCharacters(in: .whitespacesAndNewlines)
        vocabCard.back = vocabCard.back.trimmingCharacters(in: .whitespacesAndNewlines)
    }
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
            deleteAction()
        } else {
            trimCard()
        }

        dismiss()
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
                textInputView(title: "Front", text: $vocabCard.front, focus: .front)
                    .tag("Front")
                    .onTapGesture {
                        focussedView = .front
                    }

                backView
                    .tag("Back")
                    .onTapGesture {
                        focussedView = .back
                    }
                    .onAppear(perform: backAppeared)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .padding([.top, .bottom])

            HStack {
                Button(selectedTab, systemImage: "arrow.clockwise.circle.fill") {
                    selectedTab = (selectedTab == "Front" ? "Back" : "Front")
                }

                Spacer()

                Button("", systemImage: "arrowtriangle.down.circle.fill", action: close)

                Spacer()

                Button("Delete", systemImage: "trash.fill", action: { showConfirmDelete = true })
                    .foregroundStyle(.red)
            }
            .padding([.leading, .trailing, .bottom], 32)
        }
        .onAppear {
            if vocabCard.front.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                focussedView = .front
            }
        }

        .alert("Do you really want to remove this card?", isPresented: $showConfirmDelete) {
            Button("No") {}

            Button("YES") {
                deleteCard()
            }
        }
    }

    private var backView: some View {
        VStack {
            textInputView(title: "Back", text: $vocabCard.back, focus: .back)

            ForEach(translationSuggestions, id: \.self) { translation in
                HStack(spacing: 16) {
                    Text(translation)

                    Button(action: {
                        addTranslation(translation)
                    }, label: {
                        Image(systemName: "plus.circle")
                    })
                    .tint(.green)

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
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .padding()
            }
        }
    }

    private func textInputView(title: String, text: Binding<String>, focus: Focus) -> some View {
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
}

// MARK: - Preview
struct CardEditView_Previews: PreviewProvider {
    static var previews: some View {
        let previewContainer = PreviewContainer()

        CardEditView(
            translator: MockTranslator(),
            vocabCard: previewContainer.newCard(),
            deleteAction: {}
        )
        .modelContainer(previewContainer.modelContainer)
    }
}
