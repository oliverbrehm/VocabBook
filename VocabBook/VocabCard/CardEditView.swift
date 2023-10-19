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

        var title: String {
            switch self {
            case .front: return "Front"
            case .back: return "Back"
            case .settings: return "Settings"
            }
        }
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
                Button(selectedTab == .front ? "Back" : "Front", systemImage: "arrow.clockwise.circle.fill") {
                    withAnimation {
                        selectedTab = (selectedTab == Tab.front ? .back : .front)
                    }
                }

                Spacer()

                Button("", systemImage: "arrowtriangle.down.circle.fill", action: close)

                Spacer()

                Button("Settings", systemImage: "gear") {
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
            textInputView(title: "Back", text: $vocabCard.back, focus: .back)

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
                Section("Set") {
                    Menu(setName) {
                        ForEach(sets) { set in
                            Button(set.name) {
                                vocabCard.vocabSet = set
                            }
                        }
                    }
                }
            }

            Section("Reset") {
                Button("Reset level", systemImage: "arrow.uturn.backward.circle") {
                    showConfirmReset = true
                }
                .alert("Do you really want to reset this card to level 0?", isPresented: $showConfirmReset) {
                    Button("No") {}

                    Button("Yes") {
                        vocabCard.level = .level0
                    }
                }

                Button("Delete card", systemImage: "trash.fill") {
                    showConfirmDelete = true
                }
                .foregroundStyle(.red)
                .alert("Do you really want to remove this card?", isPresented: $showConfirmDelete) {
                    Button("No") {}

                    Button("YES") {
                        deleteCard()
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
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
