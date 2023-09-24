//
//  VocabSet.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 24.09.23.
//  Copyright © 2023 Oliver Brehm. All rights reserved.
//

import SwiftData

@Model
class VocabSet {
    var name: String
    var cards: [VocabCard] = []

    init(name: String) {
        self.name = name
    }
}


@Model
class VocabCard {
    var front: String
    var back: String

    init(front: String, back: String) {
        self.front = front
        self.back = back
    }
}
