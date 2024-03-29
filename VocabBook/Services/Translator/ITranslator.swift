//
//  ITranslator.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 29.09.23.
//  Copyright © 2023 Oliver Brehm. All rights reserved.
//

import Foundation

// TODO: translation suggestion feature not to be released yet
protocol ITranslator: ObservableObject {
    func queryTranslationSuggestions(for text: String) async -> [String]
}
