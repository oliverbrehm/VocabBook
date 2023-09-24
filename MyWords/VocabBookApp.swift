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
    @UIApplicationDelegateAdaptor(VBAppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            MainView()
                .modelContainer(for: [VocabSet.self, VocabCard.self])
        }
    }
}

struct LegacyAppContainer: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        let storyboard = UIStoryboard(name: "Main_iPhone", bundle: .main)
        return storyboard.instantiateViewController(withIdentifier: "MainVC") as? UINavigationController ?? UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {

    }
}
