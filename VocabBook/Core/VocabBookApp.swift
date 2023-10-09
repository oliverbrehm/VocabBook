//
//  VocabBookApp.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 24.09.23.
//  Copyright © 2023 Oliver Brehm. All rights reserved.
//

import SwiftUI
import SwiftData

@main
struct VocabBookApp: App {
    let legacyDocumentManager = VBDocumentManager()

    let modelContainer = try! ModelContainer(for: VocabSet.self, VocabCard.self)

    @AppStorage("swiftDataMigrationLocalDone") var swiftDataMigrationLocalDone = false
    @AppStorage("swiftDataMigrationiCloudDone") var swiftDataMigrationiCloudDone = false

    init() {
        migrateLegacyDocuments()
    }

    func migrateLegacyDocuments() {
        if !swiftDataMigrationLocalDone {
            legacyDocumentManager.openLocalDocument()
            migrateData()
            swiftDataMigrationLocalDone = true
        }

        if !swiftDataMigrationiCloudDone {
            legacyDocumentManager.openiCloudDocument()

            NotificationCenter.default.addObserver(forName: NSNotification.Name("LegacyCoreDataReceivedICloudUpdate"), object: nil, queue: nil) { _ in
                migrateData()
                swiftDataMigrationiCloudDone = true
            }
        }
    }

    private func migrateData() {
        let managedObjectContext = legacyDocumentManager.document.managedObjectContext
        let setRequest = NSFetchRequest<WordSet>(entityName: "WordSet")

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            do {
                let sets = try managedObjectContext.fetch(setRequest)

                for set in sets {
                    guard !set.name.isEmpty else { continue }

                    let vocabSet = VocabSet(name: set.name, descriptionText: set.descriptionText)
                    modelContainer.mainContext.insert(vocabSet)

                    for word in set.words {
                        guard let word = word as? Word else { continue }
                        
                        let vocabCard = VocabCard(front: word.name, back: word.translations)
                        modelContainer.mainContext.insert(vocabCard)
                        vocabSet.cards.append(vocabCard)
                    }
                }
            } catch {
                print("fetch error: \(error)")
            }
        })
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .modelContainer(modelContainer)
//            TestView(managedObjectContext: legacyDocumentManager.document.managedObjectContext)
//            LegacyAppContainer()
        }
    }
}

struct LegacyAppContainer: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        let storyboard = UIStoryboard(name: "Main_iPhone", bundle: .main)
        return storyboard.instantiateViewController(withIdentifier: "MainVC") as? UINavigationController ?? UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

struct TestView: View {
    // MARK: - Environment

    // MARK: - State
    @State var sets = [WordSet]()
    @State var words = [Word]()

    // MARK: - Properties
    let managedObjectContext: NSManagedObjectContext
    //let appDelegate: VBAppDelegate

    // MARK: - Functions

    // MARK: - Private properties

    // MARK: - Private functions
}

// MARK: - Actions
extension TestView {

    private func queryData() {
        let setRequest = NSFetchRequest<WordSet>(entityName: "WordSet")
        let wordRequest = NSFetchRequest<Word>(entityName: "Word")

        do {
            sets = try managedObjectContext.fetch(setRequest)
            words = try managedObjectContext.fetch(wordRequest)
        } catch {
            print("fetch error: \(error)")
        }
    }
}

// MARK: - UI
extension TestView {
    var body: some View {
        VStack {
            Text("\nSets\n")

            ForEach(sets, id: \.objectID) { set in
                Text("Set: \(set.name)")
            }

            /*Text("\nWords\n")

            ForEach(words, id: \.objectID) { word in
                Text("Word: \(word.name)")
            }*/
        }
        .onAppear(perform: queryData)
    }
}

// MARK: - Preview
struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView(managedObjectContext: NSManagedObjectContext())
    }
}
