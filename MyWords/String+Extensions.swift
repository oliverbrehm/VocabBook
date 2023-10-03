//
//  String+Extensions.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 02.10.23.
//  Copyright © 2023 Oliver Brehm. All rights reserved.
//

import Foundation

extension String {
    var lines: [String] {
        components(separatedBy: "\n").map { String($0) }
    }

    var firstLine: String {
        guard !isEmpty else { return "" }
        return firstLines(1)
    }

    func firstLines(_ n: Int, padding: Bool = false) -> String {
        guard n > 0 else { return "" }

        let endIndex = min(lines.count, n)

        var linesString = lines[0 ..< endIndex].map { String($0) }.joined(separator: "\n")

        if padding {
            while linesString.lines.count < n {
                linesString += "\n"
            }
        }

        return linesString
    }
}
